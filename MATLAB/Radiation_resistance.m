function Radiation_resistance(dr,CPW_thickness)
load([dr '/R_Ohm.mat'],"R_ohm_real","R_ohm_imag");
load([dr '/R_rad.mat'],"R_rad_real","R_rad_imag");

figure(422)
yyaxis left
plot(CPW_thickness, R_ohm_real,'Marker','o','LineWidth',1)
hold on
plot(CPW_thickness, R_rad_real,'Marker','o','LineWidth',1)
hold off
ylabel('R_{\Omega} and R_{rad} (\Omega)')

yyaxis right
plot(CPW_thickness, R_rad_real./R_ohm_real,'Marker','o','LineWidth',1)
legend('R_{\Omega} (\Omega)','R_{rad} (\Omega)','R_{rad}/R_{\Omega}',Location='north')
ylabel('R_{rad}/R_{\Omega}')
ylim([0 3])

grid on
xlim([130 920])
xticks(CPW_thickness)
xlabel('CPW thickness (nm)')
set(gca,"FontSize",14)
set(gca,"LineWidth",1)
% SaveFig('figure/electric_properties/', 'R_rad', gcf);