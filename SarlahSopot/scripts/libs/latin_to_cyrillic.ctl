string latinToCyrillic(string s) {
  strreplace(s, "\n", "**");

  if(getActiveLang() > 0) {

    mapping m,n;
    m["a"] = "а";
    m["b"] = "б";
    m["c"] = "ц";
    m["č"] = "ч";
    m["ć"] = "ћ";
    m["d"] = "д";
    m["dž"] = "џ";
    m["đ"] = "ђ";
    m["e"] = "е";
    m["f"] = "ф";
    m["g"] = "г";
    m["h"] = "х";
    m["i"] = "и";
    m["k"] = "к";
    m["lj"] = "љ";
    m["m"] = "м";
    m["nj"] = "њ";
    m["o"] = "о";
    m["p"] = "п";
    m["r"] = "р";
    m["s"] = "с";
    m["š"] = "ш";
    m["t"] = "т";
    m["u"] = "у";
    m["v"] = "в";
    m["z"] = "з";
    m["ž"] = "ж";
    m["A"] = "А";
    m["B"] = "Б";
    m["C"] = "Ц";
    m["Č"] = "Ч";
    m["Ć"] = "Ћ";
    m["D"] = "Д";
    m["DŽ"] = "Џ";
    m["Đ"] = "Ђ";
    m["E"] = "Е";
    m["F"] = "Ф";
    m["G"] = "Г";
    m["H"] = "Х";
    m["I"] = "И";
    m["K"] = "К";
    m["LJ"] = "Љ";
    m["M"] = "М";
    m["NJ"] = "Њ";
    m["O"] = "О";
    m["P"] = "П";
    m["R"] = "Р";
    m["S"] = "С";
    m["Š"] = "Ш";
    m["T"] = "Т";
    m["U"] = "У";
    m["V"] = "В";
    m["Z"] = "З";
    m["Ž"] = "Ж";
    m["0"] = "0";
    m["1"] = "1";
    m["2"] = "2";
    m["3"] = "3";
    m["4"] = "4";
    m["5"] = "5";
    m["6"] = "6";
    m["7"] = "7";
    m["8"] = "8";
    m["9"] = "9";

    n["j"] = "ј";
    n["l"] = "л";
    n["n"] = "н";
    n["L"] = "Л";
    n["N"] = "Н";
    n["J"] = "Ј";


    for (int i=1; i <= mappinglen(m); i++)
    {
      if (strpos(s, mappingGetKey(m,i), 0) >= 0) {
         strreplace(s, mappingGetKey(m,i), mappingGetValue(m,i));
      }
    }

    for (int i=1; i <= mappinglen(n); i++)
    {
      if (strpos(s, mappingGetKey(n,i), 0) >= 0) {
         strreplace(s, mappingGetKey(n,i), mappingGetValue(n,i));
      }
    }
  }

  strreplace(s, "**", "\n");
  return s;
}
