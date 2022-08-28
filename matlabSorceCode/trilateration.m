function [x_approx,y_approx]=trilateration(n,d,database_pos)
%trilateration for location estimation
%(https://www.researchgate.net/profile/Azubuike_Aniedu/publication/262232977_Tilateration_Based_Localization_Algorithm_for_Wireless_Sensor_Network/links/5784e7df08ae37d3af6da8ea/Tilateration-Based-Localization-Algorithm-for-Wireless-Sensor-Network.pdf)
n1=n(1);
n2=n(2);
n3=n(3);
d1=d(1);
d2=d(2);
d3=d(3);
x1=database_pos(n1,1);     y1=database_pos(n1,2);
x2=database_pos(n2,1);     y2=database_pos(n2,2);
x3=database_pos(n3,1);     y3=database_pos(n3,2);

if x2 == x3 %to avoid inf values of x_approx
    %fprintf('***nodes swapped to avoid inf results.\n');
    x1=database_pos(n2,1);     y1=database_pos(n2,2);
    x2=database_pos(n1,1);     y2=database_pos(n1,2);
    [d1, d2] = deal(d2,d1);
end
temp1=((d2.^2-d3.^2)-(x2.^2-x3.^2)-(y2.^2-y3.^2))/2;
temp2=((d2.^2-d1.^2)-(x2.^2-x1.^2)-(y2.^2-y1.^2))/2;
y_approx=(temp2*(x3-x2)-temp1*(x1-x2))/((y1-y2)*(x3-x2)-(y3-y2)*(x1-x2));
x_approx=(temp1-y_approx*(y3-y2))/(x3-x2);
end
