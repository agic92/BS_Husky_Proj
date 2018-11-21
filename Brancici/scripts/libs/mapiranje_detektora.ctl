string getNazivDetektora(string detektor) {
  mapping m;
/*------------------------------------------------------------------------------*/
  m["SOS-1D-A_J"] = "1.2.1 SOS-1D";
  m["SOS-1D-PP1"] = "1.2.3/1 SOS-1D PP aparat 1";
  m["SOS-1D-PP2"] = "1.2.3/2 SOS-1D PP aparat 2";
  m["SOS-1D-R_J"] = "1.2.2 R.J. SOS-1D";

  m["SOS-2D-A_J"] = "1.2.4 SOS-2D";
  m["SOS-2D-PP1"] = "1.2.6/1 SOS-2D PP aparat 1";
  m["SOS-2D-PP2"] = "1.2.6/2 SOS-2D PP aparat 2";
  m["SOS-2D-R_J"] = "1.2.5 R.J. SOS-2D";

  m["SOS-3D-A_J"] = "1.2.7 SOS-3D";
  m["SOS-3D-PP1"] = "1.2.9/1 SOS-3D PP aparat 1";
  m["SOS-3D-PP2"] = "1.2.9/2 SOS-3D PP aparat 2";
  m["SOS-3D-R_J"] = "1.2.8 R.J. SOS-3D";

  m["SOS-4D-A_J"] = "1.2.10 SOS-4D";
  m["SOS-4D-PP1"] = "1.2.12/1 SOS-4D PP aparat 1";
  m["SOS-4D-PP2"] = "1.2.12/2 SOS-4D PP aparat 2";
  m["SOS-4D-R_J"] = "1.2.11 R.J. SOS-4D";

  m["SOS-5D-A_J"] = "1.2.13 SOS-5D";
  m["SOS-5D-PP1"] = "1.2.15/1 SOS-5D PP aparat 1";
  m["SOS-5D-PP2"] = "1.2.15/2 SOS-5D PP aparat 2";
  m["SOS-5D-R_J"] = "1.2.14 R.J. SOS-5D";

  m["SOS-6D-A_J"] = "2.2.7 SOS-6D";
  m["SOS-6D-PP1"] = "2.2.9/1 SOS-6D PP aparat 1";
  m["SOS-6D-PP2"] = "2.2.9/2 SOS-6D PP aparat 2";
  m["SOS-6D-R_J"] = "2.2.8 R.J. SOS-6D";

  m["SOS-7D-A_J"] = "2.2.10 SOS-7D";
  m["SOS-7D-PP1"] = "2.2.12/1 SOS-7D PP aparat 1";
  m["SOS-7D-PP2"] = "2.2.12/2 SOS-7D PP aparat 2";
  m["SOS-7D-R_J"] = "2.2.11 R.J. SOS-7D";

  m["SOS-8D-A_J"] = "2.2.13 SOS-8D";
  m["SOS-8D-PP1"] = "2.2.15/1 SOS-8D PP aparat 1";
  m["SOS-8D-PP2"] = "2.2.15/2 SOS-8D PP aparat 2";
  m["SOS-8D-R_J"] = "2.2.14 R.J. SOS-8D";

  m["SOS-9D-A_J"] = "2.2.16 SOS-9D";
  m["SOS-9D-PP1"] = "2.2.18/1 SOS-9D PP aparat 1";
  m["SOS-9D-PP2"] = "2.2.18/2 SOS-9D PP aparat 2";
  m["SOS-9D-R_J"] = "2.2.17 R.J. SOS-9D";
/*------------------------------------------------------------------------------*/
  m["SOS-1L-A_J"] = "1.3.1 SOS-1L";
  m["SOS-1L-PP1"] = "1.3.3/1 SOS-1L PP aparat 1";
  m["SOS-1L-PP2"] = "1.3.3/2 SOS-1L PP aparat 2";
  m["SOS-1L-R_J"] = "1.3.2 R.J. SOS-1L";

  m["SOS-2L-A_J"] = "1.3.4 SOS-2L";
  m["SOS-2L-PP1"] = "1.3.6/1 SOS-2L PP aparat 1";
  m["SOS-2L-PP2"] = "1.3.6/2 SOS-2L PP aparat 2";
  m["SOS-2L-R_J"] = "1.3.5 R.J. SOS-2L";

  m["SOS-3L-A_J"] = "1.3.7 SOS-3L";
  m["SOS-3L-PP1"] = "1.3.9/1 SOS-3L PP aparat 1";
  m["SOS-3L-PP2"] = "1.3.9/2 SOS-3L PP aparat 2";
  m["SOS-3L-R_J"] = "1.3.8 R.J. SOS-3L";

  m["SOS-4L-A_J"] = "1.3.10 SOS-4L";
  m["SOS-4L-PP1"] = "1.3.12/1 SOS-4L PP aparat 1";
  m["SOS-4L-PP2"] = "1.3.12/2 SOS-4L PP aparat 2";
  m["SOS-4L-R_J"] = "1.3.11 R.J. SOS-4L";

  m["SOS-5L-A_J"] = "1.3.13 SOS-5L";
  m["SOS-5L-PP1"] = "1.3.15/1 SOS-5L PP aparat 1";
  m["SOS-5L-PP2"] = "1.3.15/2 SOS-5L PP aparat 2";
  m["SOS-5L-R_J"] = "1.3.14 R.J. SOS-5L";

  m["SOS-6L-A_J"] = "2.3.10 SOS-6L";
  m["SOS-6L-PP1"] = "2.3.12/1 SOS-6L PP aparat 1";
  m["SOS-6L-PP2"] = "2.3.12/2 SOS-6L PP aparat 2";
  m["SOS-6L-R_J"] = "2.3.11 R.J. SOS-6L";

  m["SOS-7L-A_J"] = "2.3.7 SOS-7L";
  m["SOS-7L-PP1"] = "2.3.9/1 SOS-7L PP aparat 1";
  m["SOS-7L-PP2"] = "2.3.9/2 SOS-7L PP aparat 2";
  m["SOS-7L-R_J"] = "2.3.8 R.J. SOS-7L";

  m["SOS-8L-A_J"] = "2.3.4 SOS-8L";
  m["SOS-8L-PP1"] = "2.3.6/1 SOS-8L PP aparat 1";
  m["SOS-8L-PP2"] = "2.3.6/2 SOS-8L PP aparat 2";
  m["SOS-8L-R_J"] = "2.3.5 R.J. SOS-8L";

  m["SOS-9L-A_J"] = "2.3.1 SOS-9L";
  m["SOS-9L-PP1"] = "2.3.3/1 SOS-9L PP aparat 1";
  m["SOS-9L-PP2"] = "2.3.3/2 SOS-9L PP aparat 2";
  m["SOS-9L-R_J"] = "2.3.2 R.J. SOS-9L";
/*------------------------------------------------------------------------------*/
  m["PP-1D"] = "1.2.3/3 PP-1D";
  m["PP-2D"] = "1.2.6/3 PP-2D";
  m["PP-3D"] = "1.2.9/3 PP-3D";
  m["PP-4D"] = "1.2.12/3 PP-4D";
  m["PP-5D"] = "1.2.15/3 PP-5D";
  m["PP-6D"] = "2.2.9/3 PP-6D";
  m["PP-7D"] = "2.2.12/3 PP-7D";
  m["PP-8D"] = "2.2.15/3 PP-8D";
  m["PP-9D"] = "2.2.18/3 PP-9D";

  m["PP-1L"] = "1.3.1/3 PP-1L";
  m["PP-2L"] = "1.3.4/3 PP-2L";
  m["PP-3L"] = "1.3.7/3 PP-3L";
  m["PP-4L"] = "1.3.10/3 PP-4L";
  m["PP-5L"] = "2.3.13/3 PP-5L";
  m["PP-6L"] = "2.3.10/3 PP-6L";
  m["PP-7L"] = "2.3.7/3 PP-7L";
  m["PP-8L"] = "2.3.4/3 PP-8L";
  m["PP-9L"] = "2.3.1/3 PP-9L";
/*------------------------------------------------------------------------------*/


  m["EP1-D"] = "2_2.12/4 EP";
  m["EP2-D"] = "2_2.18/4 EP2";
  m["EP3-D"] = "1_1.32/4 EP-3";
  m["EP1-L"] = "2_1.17/4 EP";
  m["EP2-L"] = "1_2.10/4 EP-2";
  m["EP3-L"] = "1_2.17/4 EP-3";

  m["V01_1-1D"] = "V1-1D";
  m["V02_2-1D"] = "V2-1D";
  m["V03_3-1D"] = "V3-1D";
  m["V04_4-1D"] = "V4-1D";
  m["V05_4-2D"] = "V4-2D";
  m["V06_3-2D"] = "V3-2D";
  m["V07_2-2D"] = "V2-2D";
  m["V08_1-2D"] = "V1-2D";
  m["V09_1D-2"] = "V1D-2";
  m["V10_2D-2"] = "V2D-2";
  m["V11_1D-4"] = "V1D-4";
  m["V12_2D-4"] = "V2D-4";
  m["V13_1D-6"] = "V1D-6";
  m["V14_2D-6"] = "V2D-6";

  m["V15_1-1L"] = "V1-1L";
  m["V16_2-1L"] = "V2-1L";
  m["V17_3-1L"] = "V3-1L";
  m["V18_4-1L"] = "V4-1L";
  m["V19_4-2L"] = "V4-2L";
  m["V20_3-2L"] = "V3-2L";
  m["V21_2-2L"] = "V2-2L";
  m["V22_1-2L"] = "V1-2L";
  m["V23_1L-2"] = "V1L-2";
  m["V24_2L-2"] = "V2L-2";
  m["V25_1L-4"] = "V1L-4";
  m["V26_2L-4"] = "V2L-4";
  m["V27_1L-6"] = "V1L-6";
  m["V28_2L-6"] = "V2L-6";





  for (int i=1; i<=mappinglen(m); i++) {
    if (mappingGetKey(m, i) == detektor) {
      return mappingGetValue(m, i);
    }
  }
  return detektor;
}
