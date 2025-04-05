import numpy as np 

class Ovf:
    def __init__(self, filename):
        self.filename = filename
        self.Nx = self.Ny = self.Nz = None
        self.dx = self.dy = self.dz = None
        self.time = None
        self.X = self.Y = self.Z = None
        self._read_header()
        self._read_data()
    
    def _read_header(self): # A headerben lévő adatok mindig latin1-ben vannak írva.
        with open(self.filename, 'r',encoding="latin1") as file:
            text = file.read().split()
        
        try:
            idx = text.index('xnodes:')
            self.Nx = int(text[idx + 1])
            self.Ny = int(text[idx + 4])
            self.Nz = int(text[idx + 7])
            
            idx = text.index('xstepsize:')
            self.dx = float(text[idx + 1])
            self.dy = float(text[idx + 4])
            self.dz = float(text[idx + 7])
            
            if 'time:' in text:
                idx = text.index('time:')
                self.time = float(text[idx + 1])
        except (ValueError, IndexError):
            raise ValueError("Invalid OVF file format.")
    
    def _read_data(self):
        with open(self.filename, 'r',encoding="latin1") as file:
            lines = file.readlines()

        for i, line in enumerate(lines):
            if 'Data' in line:
                data_start = i + 1
                if 'Text' in line:# Text módban van elmentve az adat
                    data = np.loadtxt(self.filename, comments='#', skiprows=data_start)
                    data = data.reshape((self.Nx, self.Ny, self.Nz, 3), order='F')
                    self.X, self.Y, self.Z = np.moveaxis(data, -1, 0)
                elif 'Binary' in line:#Binary módban van elmentve az adat
                    with open(self.filename, 'rb') as file:
                        for i in range(data_start):
                            next(file)
                        control = np.fromfile(file, dtype=np.float32, count=1)[0]
                        if control != 1234567:
                            raise ValueError(f"Incorrect control sequence, expected 1234567, received {control}")
                        floats = np.fromfile(file, dtype=np.float32)[:-9].reshape((3, self.Nx * self.Ny * self.Nz), order='F')
                        self.X, self.Y, self.Z = [arr.reshape((self.Nx, self.Ny, self.Nz), order='F') for arr in floats]
                else:
                    raise ValueError("Data section not found in OVF file.")
                break
            
    
    def write_ovf(self, filename, title, unit='T', label='B'):
        with open(filename, 'w') as file:
            file.write("# OOMMF OVF 2.0\n")
            file.write("# Segment count: 1\n")
            file.write("# Begin: Segment\n")
            file.write("# Begin: Header\n")
            file.write(f"# Title: {title} GHz\n")
            file.write("# meshtype: rectangular\n")
            file.write("# meshunit: m\n")
            file.write(f"# xbase: {self.dx / 2:E}\n")
            file.write(f"# ybase: {self.dz / 2:E}\n")
            file.write(f"# zbase: {self.dy / 2:E}\n")
            file.write(f"# xstepsize: {self.dx:E}\n")
            file.write(f"# ystepsize: {self.dy:E}\n")
            file.write(f"# zstepsize: {self.dz:E}\n")
            file.write(f"# xnodes: {self.Nx}\n")
            file.write(f"# ynodes: {self.Ny}\n")
            file.write(f"# znodes: {self.Nz}\n")
            file.write("# xmin: 0\n")
            file.write("# ymin: 0\n")
            file.write("# zmin: 0\n")
            file.write(f"# xmax: {self.Nx * self.dx:E}\n")
            file.write(f"# ymax: {self.Ny * self.dy:E}\n")
            file.write(f"# zmax: {self.Nz * self.dz:E}\n")
            file.write(f"# valuelabels: {label}_x {label}_y {label}_z\n")
            file.write(f"# valueunits: {unit} {unit} {unit}\n")
            file.write("# valuedim: 3\n")
            file.write("# End: Header\n")
            file.write("# Begin: Data Text\n")
            
            data = np.stack([self.X, self.Y, self.Z], axis=-1)
            np.savetxt(file, data.reshape(-1, 3, order='F'), fmt='%g')
            
            file.write("# End: Data Text\n")
            file.write("# End: Segment\n")
