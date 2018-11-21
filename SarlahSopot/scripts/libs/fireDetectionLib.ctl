void changeFireIndicatorColors(string color, int indicatorsCount, bool visibility = false)
{
  for (int i = 1; i <= indicatorsCount; i++)
  {
    setValue("FireIndicator" + i, "backCol", color);
  }
}

string getDetectorName(string detectorDatapoint) {
  mapping m;

//  m["SOS-1L-MD"] = "1.2.2 SOS-1L R.J.";
  m["EP-1_LTC_Ispred_Rucni_Javljac_Sarani"] = "2_1.25 R.J. ispred EP-1";
  m["EP-1_Unutar_Rucni_Javljac_Sarani"] = "2_1.24 R.J. u EP-1";
  m["EP-2_DTC_Ispred_Rucni_Javljac_Sarani"] = "1_1.37 EP-2";
  m["EP-2_LTC_Ispred_Rucni_Javljac_Sarani"] = "2_1.23 R.J. ispred EP-2";
  m["EP-2_Unutar_Rucni_Javljac_Sarani"] = "2_1.22 R.J. u EP-2";
  m["EP-3_DTC_Ispred_Rucni_Javljac_Sarani"] = "1_1.38 EP-3";
  m["EP-3_LTC_Ispred_Rucni_Javljac_Sarani"] = "1_2_07 R.J. ispred EP-3";
  m["EP-3_Unutar_Rucni_Javljac_Sarani"] = "1_2_08 R.J. u EP-3";
  m["Izlaz_DTC_Rucni_Javljac_Sarani"] = "1_1.23 R.J. Ulaz u tunel";
  m["Izlaz_LTC_Rucni_Javljac_Sarani"] = "2_1.26 R.J. Ulaz u tunel";

  m["SOS-1D-EXT1"] = "1.3.16 SOS-1D PP aparat";
  m["SOS-1D-MD"] = "1.3.17 SOS-1D R.J.";
  m["SOS-1D-MSD"] = "1.3.18 SOS-1D";
  m["EN-1D-MSD"] = "1.3.1 EN-1D";
  m["SOS-2D-EXT1"] = "1.3.13 SOS-2D PP aparat";
  m["SOS-2D-MD"] = "1.3.14 SOS-2D R.J.";
  m["SOS-2D-MSD"] = "1.3.15 SOS-2D";
  m["EP-D-MD"] = "1.3.2 EP-D R.J.";
  m["EP-D-MSD"] = "1.2.20 EP-D";
  m["SOS-3D-EXT1"] = "1.3.10 SOS-3D PP aparat";
  m["SOS-3D-MD"] = "1.3.11 SOS-3D R.J.";
  m["SOS-3D-MSD"] = "1.3.12 SOS-3D";
  m["EN-2D-MSD"] = "1.3.3 EN-2D";
  m["SOS-4D-EXT1"] = "1.3.7 SOS-4D PP aparat";
  m["SOS-4D-MD"] = "1.3.8 SOS-4D R.J.";
  m["SOS-4D-MSD"] = "1.3.9 SOS-4D";
  m["SOS-5D-EXT1"] = "1.3.4 SOS-5D PP aparat";
  m["SOS-5D-MD"] = "1.3.5 SOS-5D R.J.";
  m["SOS-5D-MSD"] = "1.3.6 SOS-5D";
  m["SOS-5L-EXT1"] = "1.2.16 SOS-5L PP aparat";
  m["SOS-5L-MD"] = "1.2.15 SOS-5L R.J.";
  m["SOS-5L-MSD"] = "1.2.14 SOS-5L";
  m["SOS-4L-EXT1"] = "1.2.13 SOS-4L PP aparat";
  m["SOS-4L-MD"] = "1.2.12 SOS-4L R.J.";
  m["SOS-4L-MSD"] = "1.2.11 SOS-4L";
  m["EN-2L-MSD"] = "1.2.17 EN-2L";
  m["SOS-3L-EXT1"] = "1.2.10 SOS-3L PP aparat";
  m["SOS-3L-MD"] = "1.2.9 SOS-3L R.J.";
  m["SOS-3L-MSD"] = "1.2.8 SOS-3L";
  m["EP-L-MD"] = "1.2.18 EP-L R.J.";
  m["EP-L-MSD"] = "1.2.19 EP-L";
  m["EN-1L-MSD"] = "1.2.21 EN-1L";
  m["SOS-2L-EXT1"] = "1.2.7 SOS-2L PP aparat";
  m["SOS-2L-MD"] = "1.2.6 SOS-2L R.J.";
  m["SOS-2L-MSD"] = "1.2.5 SOS-2L";
  m["SOS-1L-EXT1"] = "1.2.4 SOS-1L PP aparat";
  m["SOS-1L-MD"] = "1.2.3 SOS-1L R.J.";
  m["SOS-1L-MSD"] = "1.2.2 SOS-1L";

  m["TK-D1_Automatski_Javljac_Sarani"] = "2_2.07 TK-D1";
  m["TK-D2_Automatski_Javljac_Sarani"] = "1_1.27 TK-D2";
  m["TK-D3_Automatski_Javljac_Sarani"] = "1_1.22 TK-D3";
  m["TK-L1_Automatski_Javljac_Sarani"] = "2_1.12 TK-L1";
  m["TK-L2_Automatski_Javljac_Sarani"] = "1_2.22 TK-L2";
  m["TS1_Automatski_Javljac1_Sarani"] = "2_1.01 Magacin";
  m["TS1_Automatski_Javljac2_Sarani"] = "2_1.02 Magacin - D.Plafon";
  m["TS1_Automatski_Javljac3_Sarani"] = "2_1.04 Hodnik - D.Plafon";
  m["TS1_Automatski_Javljac4_Sarani"] = "2_1.07 Hodnik";
  m["TS1_Automatski_Javljac5_Sarani"] = "2_1.08 Elektro ormani";
  m["TS1_Automatski_Javljac6_Sarani"] = "2_1.09 Agregat";
  m["TS1_Automatski_Javljac7_Sarani"] = "2_1.10 Trafo";
  m["TS1_Automatski_Javljac8_Sarani"] = "2_1.11 UPS";
  m["TS1_Ormani_D_Pod"] = "2_1.05 Elektro ormani - D.Pod";
  m["TS1_Trafo_D_Pod"] = "2_1.06 Trafo - D.Pod";
  m["TS1_Rucni_Javljac_Sarani"] = "2_1.03 R.J. Hodnik";
  m["TS2_Automatski_Javljac1_Sarani"] = "1_1.01 CSNU";
  m["TS2_Automatski_Javljac10_Sarani"] = "1_1.12 Elektro ormani";
  m["TS2_Automatski_Javljac11_Sarani"] = "1_1.14 Hodnik kod UPS-a - D.Plafon";
  m["TS2_Automatski_Javljac12_Sarani"] = "1_1.15 Hodnik kod UPS-a";
  m["TS2_Automatski_Javljac13_Sarani"] = "1_1.18 Hodnik kod magacina - D.Plafon";
  m["TS2_Automatski_Javljac14_Sarani"] = "1_1.19 Hodnik kod magacina";
  m["TS2_Automatski_Javljac15_Sarani"] = "1_1.20 Hodnik ulaz - D.Plafon";
  m["TS2_Automatski_Javljac16_Sarani"] = "1_1.21 Hodnik ulaz";
  m["TS2_Automatski_Javljac2_Sarani"] = "1_1.02 CSNU - D.Plafon";
  m["TS2_Automatski_Javljac3_Sarani"] = "1_1.03 Rack soba";
  m["TS2_Automatski_Javljac4_Sarani"] = "1_1.06  Rack soba - D.Plafon";
  m["TS2_Automatski_Javljac5_Sarani"] = "1_1.07 Magacin";
  m["TS2_Automatski_Javljac6_Sarani"] = "1_1.08 Magacin - D.Plafon";
  m["TS2_Automatski_Javljac7_Sarani"] = "1_1.09 UPS";
  m["TS2_Automatski_Javljac8_Sarani"] = "1_1.10 Trafo";
  m["TS2_Automatski_Javljac9_Sarani"] = "1_1.11 Agregat";
  m["TS2_Rucni_Javljac_Sarani"] = "1_1.13 R.J. Hodnik ulaz";
  m["TS2_CSNU_D_Pod"] = "1_1.04 CSNU - D.Pod";
  m["TS2_Rack_Soba_D_Pod"] = "1_1.05 Rack soba - D.Pod";
  m["TS2_Ormani_D_Pod"] = "1_1.16 Elektro ormani - D.Pod";
  m["TS2_Trafo_D_Pod"] = "1_1.17 Trafo - D.Pod";
  m["Ulaz_DTC_Rucni_Javljac_Sarani"] = "2_2.06 R.J. Ulaz u tunel";
  m["Ulaz_LTC_Rucni_Javljac_Sarani"] = "1_2_06 R.J. Ulaz u tunel";

  m["H-D1"] = "2_2.09/3 H-D1";
  m["H-D2"] = "2_2.12/3 H-D2";
  m["H-D3"] = "2_2.15/3 H-D3";
  m["H-D4"] = "2_2.18/3 H-D4";
  m["H-D4_1"] = "2_2.19/1 H-4.1";
  m["H-D5"] = "1_1.35/3 H-D5";
  m["H-D6"] = "1_1.32/3 H-D6";
  m["H-D7"] = "1_1.29/3 H-D7";
  m["H-D8"] = "1_1.25/3 H-D8";
  m["H-L1"] = "2_1.14/3 H-L1";
  m["H-L2"] = "2_1.17/3 H-L2";
  m["H-L3"] = "2_1.20/3 H-L3";
  m["H-L4"] = "1_2.10/3 H-L4";
  m["H-L4_1"] = "1_2.11/1 H-L4.1";
  m["H-L5"] = "1_2.14/3 H-L5";
  m["H-L6"] = "1_2.17/3 H-L6";
  m["H-L7"] = "1_2.20/3 H-L7";
  m["H-L8"] = "1_2.23/1 H-L8";

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
    if (mappingGetKey(m, i) == detectorDatapoint) {
      return mappingGetValue(m, i);
    }
  }
  return detectorDatapoint;
}
