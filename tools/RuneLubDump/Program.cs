using System.Text;
using System.Text.Json;

// Minimal Lua 5.1 bytecode VM (data-only) that evaluates a client data .lub and
// dumps the tables assigned to globals as JSON. Handles the opcode subset used by
// pure data tables (no real control flow / arithmetic needed).

class Reader {
    byte[] d; int p; public int sizeT;
    public Reader(byte[] data){ d=data; p=0; }
    public byte U8()=>d[p++];
    public int I32(){ int v=BitConverter.ToInt32(d,p); p+=4; return v; }
    public long SizeT(){ if(sizeT==8){ long v=BitConverter.ToInt64(d,p); p+=8; return v;} else { long v=BitConverter.ToUInt32(d,p); p+=4; return v;} }
    public double Number(){ double v=BitConverter.ToDouble(d,p); p+=8; return v; }
    public uint Instr(){ uint v=BitConverter.ToUInt32(d,p); p+=4; return v; }
    public string? Str(){ long n=SizeT(); if(n==0) return null; var s=Encoding.ASCII.GetString(d,p,(int)n-1); p+=(int)n; return s; }
}

class Const { public int type; public double num; public string? str; }
class Proto {
    public List<uint> code = new();
    public List<Const> consts = new();
    public List<Proto> protos = new();
}

// runtime value: null, double, string, bool, LTable
class LTable {
    public Dictionary<object,object?> hash = new();
    public List<object?> arr = new(); // 1-based array part appended here
}

class Program {
    static Reader R = null!;
    static Dictionary<string,object?> G = new();

    static Proto ReadProto(){
        var pr = new Proto();
        R.Str(); R.I32(); R.I32(); R.U8(); R.U8(); R.U8(); R.U8();
        int nc = R.I32(); for(int i=0;i<nc;i++) pr.code.Add(R.Instr());
        int nk = R.I32();
        for(int i=0;i<nk;i++){
            var c=new Const(); int t=R.U8(); c.type=t;
            switch(t){ case 0: break; case 1: R.U8(); break; case 3: c.num=R.Number(); break; case 4: c.str=R.Str(); break; default: throw new Exception("const "+t); }
            pr.consts.Add(c);
        }
        int np=R.I32(); for(int i=0;i<np;i++) pr.protos.Add(ReadProto());
        int nl=R.I32(); for(int i=0;i<nl;i++) R.I32();
        int nlo=R.I32(); for(int i=0;i<nlo;i++){ R.Str(); R.I32(); R.I32(); }
        int nu=R.I32(); for(int i=0;i<nu;i++) R.Str();
        return pr;
    }

    static object? KVal(Const c)=> c.type==3 ? (object)c.num : c.type==4 ? c.str : null;

    static void Exec(Proto pr){
        var reg = new object?[512];
        var code = pr.code;
        for(int pc=0; pc<code.Count; pc++){
            uint ins=code[pc];
            int op=(int)(ins&0x3F);
            int a=(int)((ins>>6)&0xFF);
            int cC=(int)((ins>>14)&0x1FF);
            int bB=(int)((ins>>23)&0x1FF);
            int bx=(int)((ins>>14)&0x3FFFF);
            int sbx=bx-131071;
            object? RK(int x){ if((x&0x100)!=0){int idx=x&0xFF; return idx<pr.consts.Count?KVal(pr.consts[idx]):null;} return reg[x]; }
            switch(op){
                case 0: reg[a]=reg[bB]; break;                       // MOVE
                case 1: reg[a]=KVal(pr.consts[bx]); break;           // LOADK
                case 2: reg[a]=(bB!=0); if(cC!=0) pc++; break;       // LOADBOOL
                case 3: for(int j=a;j<=a+bB;j++) reg[j]=null; break; // LOADNIL
                case 5: { var k=pr.consts[bx].str!; reg[a]=G.TryGetValue(k,out var gv)?gv:null; break; } // GETGLOBAL
                case 6: { // GETTABLE A B C
                    var tbl=reg[bB] as LTable; var key=RK(cC);
                    reg[a]= (tbl!=null&&key!=null&&tbl.hash.TryGetValue(Norm(key),out var vv))?vv:null; break; }
                case 7: { var k=pr.consts[bx].str!; G[k]=reg[a]; break; } // SETGLOBAL
                case 9: { // SETTABLE A B C
                    var tbl=reg[a] as LTable; var key=RK(bB); var val=RK(cC);
                    if(tbl!=null && key!=null) tbl.hash[Norm(key)]=val; break; }
                case 10: reg[a]=new LTable(); break;                 // NEWTABLE
                case 34: { // SETLIST A B C
                    var tbl=reg[a] as LTable; if(tbl==null) break;
                    int n=bB; int block=cC;
                    if(block==0){ block=(int)code[++pc]; }
                    if(n==0){ // up to top - count actual set regs after a
                        n=0; while(a+1+n<reg.Length && reg[a+1+n]!=null) n++;
                    }
                    int baseIdx=(block-1)*50;
                    for(int j=1;j<=n;j++){ int slot=baseIdx+j; while(tbl.arr.Count<slot) tbl.arr.Add(null); tbl.arr[slot-1]=reg[a+j]; }
                    break; }
                case 30: { // RETURN A B  (B-1 values from reg[A]; capture first table)
                    if(bB!=1 && reg[a] is LTable) G["__return__"]=reg[a];
                    return; }
                default: break;  // ignore arithmetic/calls in data files
            }
        }
    }

    static object Norm(object k){ if(k is double d && d==Math.Floor(d)) return (long)d; return k; }

    // ---- JSON serialization ----
    static object? ToJson(object? v){
        if(v is LTable t){
            bool arrayLike = t.hash.Count==0 && t.arr.Count>0;
            if(t.arr.Count>0 && t.hash.Count==0){
                var list=new List<object?>(); foreach(var e in t.arr) list.Add(ToJson(e)); return list;
            }
            var m=new Dictionary<string,object?>();
            foreach(var kv in t.hash) m[kv.Key.ToString()!]=ToJson(kv.Value);
            for(int i=0;i<t.arr.Count;i++) if(t.arr[i]!=null) m["["+(i+1)+"]"]=ToJson(t.arr[i]);
            return m;
        }
        if(v is double d){ if(d==Math.Floor(d)) return (long)d; return d; }
        return v;
    }

    static void RunFile(string path){
        var bytes=File.ReadAllBytes(path);
        R=new Reader(bytes);
        // header 12 bytes
        for(int i=0;i<4;i++) R.U8();     // ESC Lua
        R.U8(); R.U8(); R.U8();          // ver, format, endian
        R.U8(); R.sizeT=R.U8(); R.U8();  // intsize, sizet, instrsize
        R.U8(); R.U8();                  // number size, integral
        var top=ReadProto();
        Exec(top);
    }

    static void Main(string[] args){
        // Args: file1[;file2;...] [wantGlobal]
        // Executes each file sequentially sharing the global environment so that
        // id tables loaded by an earlier file resolve GETGLOBAL in a later file.
        var files=args[0].Split(';');
        foreach(var f in files) RunFile(f);
        string? want=args.Length>1?args[1]:null;
        var outMap=new Dictionary<string,object?>();
        foreach(var kv in G){ if(want!=null && kv.Key!=want) continue; if(kv.Value is LTable) outMap[kv.Key]=ToJson(kv.Value); }
        Console.WriteLine(JsonSerializer.Serialize(outMap, new JsonSerializerOptions{ WriteIndented=true }));
    }
}
