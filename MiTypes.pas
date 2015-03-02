Unit MiTypes;

Interface

Uses
 Unixtype,BaseUnix;

Type
          salida = array of ansistring;
          ArrayChar = array of char;
          RegPid =  Record
					j_pid:integer;
					j_estado:string;
					j_nombre:string;
					end;
					
			

Const
meses: array[1..12] of string=('ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic');


dias: array[1..31] of string=(' 1',' 2',' 3',' 4',' 5',' 6',' 7',' 8',' 9','10','11','12','13','14','15','16','17','18','19','20',   '21','22','23','24','25','26','27','28','29','30','31');


numero: array[0..59] of string=('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20',
'21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43',
'44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59');

comandos: array[1..10] of string=('mils -l','mils -a','mils -fR','micat','micd','mipwd','mikill','mibg','mifg','mijobs');

BUFF_MAX = 500;

Var
		resPipe,usuarioActual,hostActual,midir,olddir,home,homeMasUsuarioActual,Entrada,Entrada2 : String;
        dat: ArrayChar;
        jIndex,pid: longint;
        idBg:TPid;
		frente, atras : cint;
		LJobs : Array of RegPid;
		job : RegPid;
		na: PsigActionRec;
		bbg,bpipe,chterm: boolean;
              fpIN,fpOut : TFilDes;
              buff : array of char;
Implementation

end.
