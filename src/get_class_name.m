function class=get_class_name(map_type)
classes=["MAP_A","Indifferent";
         "MAP_B","Effective";
         "MAP_C","Dangerous";];

class=classes(strcmp(map_type,classes(:,1)),2);