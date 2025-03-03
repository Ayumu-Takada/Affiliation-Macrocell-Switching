function coordinates = create_bs_coordinate( optional_intersite_distance )

if nargin > 0
    intersite_distance = optional_intersite_distance;
else
    intersite_distance = 189;
end

no_cell = 7; 
coordinates = zeros(no_cell, 1);

coordinates(1) = 0;         % cell 1 is the center

for a = 2:7
    coordinates(a) = intersite_distance * cos((a+1) * pi/3 - pi/6) ...
                             + 1i * intersite_distance * sin((a+1) * pi/3 - pi/6);
end

end

