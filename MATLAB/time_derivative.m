function Ey=time_derivative(Ay)
% Approximate time derivative with central differences
    dAY = diff(Ay,1,1);

    dtime = diff(time);
    dtc = [dtime(1);dtime]+[dtime;dtime(end)];

    Ey = -([dAY(1,:,:,:);dAY]+[dAY;dAY(end,:,:,:)])./dtc;
end