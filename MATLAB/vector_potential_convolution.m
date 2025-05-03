function Ay=vector_potential_convolution(Mx,Mz,RTX,RTZ,A_,cpw_pos)
    % calculating vector potential (A) with convolution
    A_cross_y = A_ * (convn(RTX,Mz,'valid') - convn(RTZ,Mx,'valid'));
    Ay = A_cross_y(cpw_pos-cpw_pos(1)+1);
end