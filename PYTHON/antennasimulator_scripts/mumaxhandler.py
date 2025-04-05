import numpy as np

def mumexgeneration(mialapjan,hovamenti,CPW_thickness,frekvencia):

    # Sablon fájl beolvasása
    with open(mialapjan, "r") as file:
        lines = file.readlines()
    # Kulcsszavak a sablon fájlban, amiket ki kell cserélni
    keywords = ["@f_exc", "@file_re", "@file_im"]
    # Megkeressük a kulcsszavak helyét
    line_idx = {kw: next(i for i, line in enumerate(lines) if kw in line) for kw in keywords}
    # Új fájlok generálása
    for i, thickness in enumerate(CPW_thickness, start=1):
        # Kicserélendő sorok
        assignment = [
            f"f_exc := {frekvencia}e9\n",
            f'file_re := "{hovamenti}/source/CPW_Real_{int(frekvencia*1000)}MHz_{thickness}nm.ohf"\n',
            f'file_im := "{hovamenti}/source/CPW_Imag_{int(frekvencia*1000)}MHz_{thickness}nm.ohf"\n'
        ]
        # Sorok frissítése
        for j, key in enumerate(keywords):
            lines[line_idx[key]] = assignment[j]
        # Új fájl neve
        newfile = hovamenti+'/'+f"mumax_f{i}.mx3"
        # Fájl mentése
        with open(newfile, "w") as file:
            file.writelines(lines)