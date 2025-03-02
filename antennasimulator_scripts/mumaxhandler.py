import numpy as np

def mumexgeneration(dr):
        # Paraméterek beállítása
    f = 6360 / 1e3  # GHz
    CPW_thickness = np.arange(150, 901, 150)  # [150, 300, 450, 600, 750, 900]
    # Paraméterek mentése
    np.save(dr+"/parameters.npy", {"CPW_thickness": CPW_thickness, "dr": dr})

    # Sablon fájl beolvasása
    with open("template.mx3", "r") as file:
        lines = file.readlines()
    # Kulcsszavak a sablon fájlban, amiket ki kell cserélni
    keywords = ["@f_exc", "@file_re", "@file_im"]
    # Megkeressük a kulcsszavak helyét
    line_idx = {kw: next(i for i, line in enumerate(lines) if kw in line) for kw in keywords}
    # Új fájlok generálása
    for i, thickness in enumerate(CPW_thickness, start=1):
        # Kicserélendő sorok
        assignment = [
            f"f_exc := {f}e9\n",
            f'file_re := "{dr}/source/CPW_Real_{int(f*1000)}MHz_{thickness}nm.ohf"\n',
            f'file_im := "{dr}/source/CPW_Imag_{int(f*1000)}MHz_{thickness}nm.ohf"\n'
        ]
        # Sorok frissítése
        for j, key in enumerate(keywords):
            lines[line_idx[key]] = assignment[j]
        # Új fájl neve
        newfile = dr+'/'+f"mumax_f{i}.mx3"
        # Fájl mentése
        with open(newfile, "w") as file:
            file.writelines(lines)

    print("Fájlok generálása kész!")

def hello():
    print('sziasztok')