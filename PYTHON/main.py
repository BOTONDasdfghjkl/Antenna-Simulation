import antennasimulator_scripts as antsim
import os
import numpy as np

# Könyvtár beállításai
dir = os.path.dirname(os.path.abspath(__file__))
dr = dir+"/6360MHz"
os.makedirs(os.path.join(dr, "images"), exist_ok=True)
os.makedirs(os.path.join(dr, "source"), exist_ok=True)

# példa
#ovf=antsim.Ovf(dir+"/m000000.ovf")

# Paraméterek beállítása
f = 6360 / 1e3  # GHz
CPW_thickness = np.arange(150, 901, 150)  # [150, 300, 450, 600, 750, 900]
# Paraméterek mentése
np.save(dr+"/parameters.npy", {"CPW_thickness": CPW_thickness, "dr": dr})

antsim.mumexgeneration(dir+'/template.mx3',dr,CPW_thickness,f)