using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
sealed class SE { public string N; public uint VA; public uint VS; public uint RS; public uint RA; }
sealed class PE { public uint IB; public List<SE> S = new List<SE>(); }
class Program {
 static StringBuilder B = new StringBuilder();
 static void L(string m) { Console.WriteLine(m); B.AppendLine(m); }
 static PE Parse(byte[] b) {
  PE p = new PE();
  int e = BitConverter.ToInt32(b, 60);
  // COFF: SizeOfOptionalHeader @ e+20; OptionalHeader starts @ e+24
  ushort so = BitConverter.ToUInt16(b, e + 20);
  int o = e + 24;
  ushort magic = BitConverter.ToUInt16(b, o);
  // PE32 ImageBase @ +28; PE32+ ImageBase @ +24 (ulong) - use low 32 for search
  p.IB = (magic == 0x20B) ? (uint)BitConverter.ToUInt64(b, o + 24) : BitConverter.ToUInt32(b, o + 28);
  ushort n = BitConverter.ToUInt16(b, e + 6);
  ushort ss = 40; // IMAGE_SIZEOF_SECTION_HEADER
  int st = o + so;
  for (int i = 0; i < n; i++) {
   int f = st + i * ss;
   int l = 0; while (l < 8 && b[f + l] != 0) l++;
   p.S.Add(new SE { N = Encoding.ASCII.GetString(b, f, l), VA = BitConverter.ToUInt32(b, f + 12), VS = BitConverter.ToUInt32(b, f + 8), RS = BitConverter.ToUInt32(b, f + 16), RA = BitConverter.ToUInt32(b, f + 20) });
  }
  return p;
 }
 static bool F2V(PE p, long fo, out uint va) {
  va = 0;
  foreach (var s in p.S) {
   if (s.RS == 0) continue;
   if (fo >= s.RA && fo < s.RA + s.RS) { va = p.IB + s.VA + (uint)(fo - s.RA); return true; }
  }
  return false;
 }
 static bool V2F(PE p, uint va, out long fo) {
  fo = -1;
  if (va < p.IB) return false;
  uint r = va - p.IB;
  foreach (var s in p.S) {
   uint sz = Math.Max(s.VS, s.RS);
   if (r >= s.VA && r < s.VA + sz) { fo = s.RA + (r - s.VA); return true; }
  }
  return false;
 }
 static List<long> FB(byte[] b, byte[] n) {
  var h = new List<long>();
  int lim = b.Length - n.Length;
  for (int i = 0; i <= lim; i++) {
   bool ok = true;
   for (int j = 0; j < n.Length; j++) if (b[i + j] != n[j]) { ok = false; break; }
   if (ok) h.Add(i);
  }
  return h;
 }
 static void HD(byte[] b, long st, int len) {
  long end = Math.Min(st + len, b.Length);
  for (long off = st; off < end;) {
   int n = (int)Math.Min(16, end - off);
   string hx = BitConverter.ToString(b, (int)off, n).Replace("-", " ");
   var asc = new StringBuilder();
   for (int k = 0; k < n; k++) { byte c = b[off + k]; asc.Append(c >= 32 && c <= 126 ? (char)c : '.'); }
   L(off.ToString("X8") + "  " + hx + " " + asc.ToString());
   off += n;
  }
 }

 static void ScanFile(string path) {
  L(new string('=', 80));
  L("FILE: " + path);
  if (!File.Exists(path)) { L("MISSING"); return; }
  byte[] b = File.ReadAllBytes(path);
  L("SIZE: " + b.Length + " (0x" + b.Length.ToString("X") + ")");
  PE pe = Parse(b);
  L("ImageBase=0x" + pe.IB.ToString("X") + " sections=" + pe.S.Count);
  foreach (var s in pe.S) L("  " + s.N + " VA=0x" + s.VA.ToString("X") + " RA=0x" + s.RA.ToString("X") + " RS=0x" + s.RS.ToString("X"));

  string[] names = new string[] {
   "CRuneSystemMgr", ".?AVCRuneSystemMgr@@", "UIRuneSystemWnd", "UIRuneSystem_DecomItemWnd", "CRuneSystemMgr file Init",
   "OPEN_RUNE", "CLOSE_RUNE", "RUNE_ACK", "CZ_RUNE", "ZC_RUNE", "RuneUI", "runeui",
   "BANKING", "STYLIST", "ENCHANTGRADE", "REPUTATION"
  };
  var stringOffs = new List<long>();
  foreach (var name in names) {
   byte[] n = Encoding.ASCII.GetBytes(name);
   var hits = FB(b, n);
   L("--- ASCII '" + name + "' hits=" + hits.Count);
   foreach (var h in hits) {
    stringOffs.Add(h);
    uint va; bool ok = F2V(pe, h, out va);
    L("  hit file=0x" + h.ToString("X") + (ok ? (" VA=0x" + va.ToString("X")) : " (no VA)"));
    // packet IDs within 512 bytes of string
    long a = Math.Max(0, h - 512); long z = Math.Min(b.Length - 2, h + 512);
    var near = new List<string>();
    for (long i = a; i <= z; i++) {
     ushort v = BitConverter.ToUInt16(b, (int)i);
     if (v >= 0x0B00 && v <= 0x0C50) near.Add("0x" + v.ToString("X4") + "@0x" + i.ToString("X"));
    }
    // consecutive XX 0B YY 0B pattern
    var consec = new List<string>();
    for (long i = a; i <= z - 5; i++) {
     ushort v1 = BitConverter.ToUInt16(b, (int)i);
     ushort v2 = BitConverter.ToUInt16(b, (int)(i + 2));
     ushort v3 = BitConverter.ToUInt16(b, (int)(i + 4));
     if (v1 >= 0x0B00 && v1 <= 0x0C50 && v2 >= 0x0B00 && v2 <= 0x0C50 && v3 >= 0x0B00 && v3 <= 0x0C50)
      consec.Add("0x" + v1.ToString("X4") + ",0x" + v2.ToString("X4") + ",0x" + v3.ToString("X4") + "@0x" + i.ToString("X"));
    }
    if (near.Count > 0) L("  near pkIDs (" + near.Count + "): " + string.Join(" ", near.GetRange(0, Math.Min(40, near.Count))));
    if (consec.Count > 0) L("  consec 0Bxx triples: " + string.Join(" | ", consec.GetRange(0, Math.Min(20, consec.Count))));
   }
  }

  var uniq = new HashSet<long>(stringOffs);
  foreach (var h in uniq) {
   uint strVa; if (!F2V(pe, h, out strVa)) continue;
   byte[] needle = BitConverter.GetBytes(strVa);
   var xrefs = FB(b, needle);
   L("--- xrefs to VA=0x" + strVa.ToString("X") + " file=0x" + h.ToString("X") + " count=" + xrefs.Count);
   int cap = 0;
   foreach (var x in xrefs) {
    if (++cap > 80) { L("  ... truncated"); break; }
    long ds = Math.Max(0, x - 128); long de = Math.Min(b.Length, x + 132);
    L("  xref file=0x" + x.ToString("X"));
    HD(b, ds, (int)Math.Min(de - ds, 256));
    var pkds = new List<string>();
    for (long i = ds; i <= de - 2; i++) {
     ushort v = BitConverter.ToUInt16(b, (int)i);
     if (v >= 0x0B00 && v <= 0x0C50) pkds.Add("0x" + v.ToString("X4") + "@0x" + i.ToString("X"));
    }
    if (pkds.Count > 0) L("  pk IDs in +/-128: " + string.Join(" ", pkds));
   }
  }
 }

 static int Main(string[] args) {
  string outPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "GitHub", "PRO-rathena", "tools", "_scan_rune_packets_deep.txt");
  L("RUNE Packet Deep Scan " + DateTime.Now.ToString("o"));
  string[] files = new string[] {
   @"c:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia - Copy\proasia.exe",
   @"c:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia - Copy\2026-01-07_Ragexe_1767686776_VHL_v5_clientinfo_patched_patched.exe",
   @"c:\Users\Mikko Tandoc\Downloads\asd\2\BossRO\BossRO.exe"
  };
  foreach (var f in files) ScanFile(f);

  L("");
  L("=== FILESYSTEM SEARCH under Downloads\\asd\\2 ===");
  try {
   string root = @"c:\Users\Mikko Tandoc\Downloads\asd\2";
   string[] pats = new string[] { "*.diff", "*.patch", "*.cpp", "*.hpp", "*.txt", "*.log" };
   string[] keys = new string[] { "0x0bc", "OPEN_RUNE", "CRune", "runeui", "CZ_RUNE", "ZC_RUNE" };
   int shown = 0;
   foreach (var pat in pats) {
    foreach (var file in Directory.EnumerateFiles(root, pat, SearchOption.AllDirectories)) {
     string text = "";
     try { text = File.ReadAllText(file); } catch { continue; }
     foreach (var key in keys) {
      int idx = text.IndexOf(key, StringComparison.OrdinalIgnoreCase);
      if (idx >= 0) {
       int a = Math.Max(0, idx - 80); int z = Math.Min(text.Length, idx + 120);
       L("HIT " + key + " in " + file);
       L("  ..." + text.Substring(a, z - a).Replace("\r", " ").Replace("\n", " ") + "...");
       if (++shown >= 50) goto donefs;
      }
     }
    }
   }
   donefs: L("filesystem hits shown=" + shown);
  } catch (Exception ex) { L("FS search error: " + ex.Message); }

  File.WriteAllText(outPath, B.ToString());
  Console.WriteLine("WROTE: " + outPath);
  return 0;
 }
}

