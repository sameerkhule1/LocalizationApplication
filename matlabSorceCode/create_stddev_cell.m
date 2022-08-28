function stddevinfo= create_stddev_cell()
stddevinfo=cell(18,5);
stddevinfo(:) = {''''''''''''''''''''''''''''};
stddevinfo(1,1)={'nearest->'};
stddevinfo(2,2)={'''''combxy'''''};
stddevinfo(2,4)={'''''''tempx'''''''};
stddevinfo(2,5)={'''''''tempy'''''''};
stddevinfo(7,3)={'stddevmat'};
stddevinfo(8,2)={'''''combx'''''''};
stddevinfo(8,4)={'''combxstd'''};
stddevinfo(8,5)={'''''x_approx'''};
stddevinfo(13,2)={'''''comby'''''''};
stddevinfo(13,4)={'''combystd'''};
stddevinfo(13,5)={'''''y_approx'''};
stddevinfo(18,1)={'true_loc->'};
end