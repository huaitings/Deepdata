open $energyraw ,">energy.raw";
open $virialraw ,">virial.raw";
open $forceraw ,">force.raw";
open $coordraw ,">coord.raw";
open $boxraw ,">box.raw";
@out = `cat *.out`;
############# energy ############
@totalenergy = `cat *.out | grep !`;
for(0..$#totalenergy){
 if($totalenergy[$_] =~ m/!\s+total\s+energy\s+\=\s+(\-?\d+\.\d+)\s+Ry/g)
 {
   push @energy,$1*13.60568496;
 }
}
$energy = join "\n",@energy; 
print $energyraw "$energy\n";
#############stress############
@totalstress = `grep -A3 "total   stress" *.out`;
#print @totalstress;
for(0..$#totalstress){
  if($totalstress[$_] =~ m/^\s+(\-?\d+\.\d+)\s+(\-?\d+\.\d+)\s+(\-?\d+\.\d+)\s+\-?\d+\.\d+\s+\-?\d+\.\d+\s+\-?\d+\.\d+/g)
  {
    push @stress,$1*1.13143935805,$2*1.13143935805,$3*1.13143935805;
  }   
}
$i=-1; 
for(0..$#stress){
    $i =$i+1;
    push @newstress,$stress[$i];
  if(($i+1) % (3*3) == 0) 
  {
      print $virialraw "@newstress\n";
      @newstress = ();
  }
}
############# force ############   #1 Ry/Bohr**3 = 1.47108E5 Kbar   Ry/Bohr**3=1.47108E8 bar 
for(0..$#out)                      #1 Ry/a.u. = 25.7110 eV/A
{                                  #1 Ry/Bohr**3 = 91.81759244 eV/A3
  if($out[$_] =~ m/\s+number\s+of\s+atoms\/cell\s+\=\s+(\d+)/g)
  {
      push @atomscell,$1+1;
  }
}
$atomscell = join "",@atomscell;
@totalforce = `grep -A$atomscell "Forces acting on atoms (cartesian axes, Ry/au):" *.out`;
for(0..$#totalforce)
{
  if($totalforce[$_] =~ m/\s+atom\s+\d+\s+type\s+\d+\s+force\s+\=\s+(\-?\d+\.\d+)\s+(\-?\d+\.\d+)\s+(\-?\d+\.\d+)/g)
  {
      push @force,$1*25.7110,$2*25.7110,$3*25.7110;
  }    
}
$j = -1; 
for(0..$#force){
    $j = $j + 1;
    push @newforce,$force[$j];
  if(($j+1) % (($atomscell-1)*3) == 0) 
  {
      print $forceraw "@newforce  \n";
      @newforce = ();
  }
}
############# coord ############
@coord = `grep -A$atomscell "ATOMIC_POSITIONS (angstrom)" *.out`;
$k = -1; 
for(0..$#coord){
    if($coord[$_] =~ m/\w+\s+(\-?\d+\.\d+\s+\-?\d+\.\d+\s+\-?\d+\.\d+)/g)
  {
   push @Cartcoord,$1
  }
}
#print  @Cartcoord;
$k = -1; 
for(0..$#Cartcoord){
    $k = $k + 1;
    push @newcoord,$Cartcoord[$k];
  if(($k+1) % ($atomscell-1) == 0) 
  {
      print $coordraw "@newcoord\n";
      @newcoord = ();
  }
}
############# box ############
@CELL_PARAMETERS = `grep -A3 "CELL_PARAMETERS (angstrom)" *.out`;
for(0..$#CELL_PARAMETERS ){
   if($CELL_PARAMETERS [$_] =~ m/\s+(\-?\d+\.\d+\s+\-?\d+\.\d+\s+\-?\d+\.\d+)/g)
  {
    push @box,$1;
  }
}
$m = -1; 
for(0..$#box){
    $m = $m + 1;
    push @newbox,$box[$m];
  if(($m+1) % 3 == 0) 
  {
      print $boxraw "@newbox\n";
      @newbox = ();
  }
}
system("sh raw_to_set.sh");
