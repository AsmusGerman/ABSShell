Unit MiUtils;


interface

Uses
   crt,strutils,BaseUnix,TDALista,users,MiResources,MiTypes,SysUtils,Unix,DateUtils,unixutil;


procedure micat1(arch1:string);
procedure micat2(arch1:string; arch2:string);
procedure mibg(P1: string);
procedure mifg(P1: string);
procedure micat;
procedure mikill(S1:string;S2:string);
procedure mipwd;
procedure micd(ruta:string);
procedure milsl (ubicacion:string;redireccion:boolean);
procedure milsa (ubicacion:string;redireccion:boolean);
procedure milsfR (ubicacion:string);
procedure mijobs;


implementation

var
   dire: Pdir;
   entrada: Pdirent;
   archivo: Stat;
   aux: T_DATOL;
   lis: T_LISTA;
   cant,total,ubi:string;
   D:TDateTime;
   YY,MM,DD,HH,MI,SS,MS : word;
   ttotal,cant_archivos:longint;


{
   name: micd
   @param
   * ruta : string
   @return
   
   *Cambia el valor de la variable global midir por ruta 
}

procedure micd(ruta:string);

begin
      if (ruta='~') then
                ruta:=homeMasUsuarioActual
                {La ruta indica al root}
                          else
                if (ruta='.') or (ruta=' ') then
                  ruta:=midir
                  {La ruta indica al directorio actual}
                else
                  if ruta= '..' then
                    begin
                        if (midir='') then
                        ruta:=''
                        else
                        ruta:=rutaPadre(midir);
        {La ruta indica al directorio padre}
                    end
                  else
                    if ruta= '-' then
                      begin
                      ruta:=olddir;
            {La ruta indica al directorio viejo}
                      end
                else
                  if copy(ruta,1,1) <> '/' then
                        begin
                      ruta:=midir+'/'+ruta;
                        end;

      if verificarRuta(ruta)=1 then
                begin
                  olddir:=midir;
                  midir:=ruta;
                end
             else
                begin
             devolverMensaje('Error ');
             devolverMensaje(ruta);
             devolverMensaje(': No existe el archivo o el directorio');
                end;
    end;


{
   
   name: milsl
   @param
   * ubicacion : string
   * redireccion : boolean
   @return
   
   *El procedimiento milsl lista los elementos en formato largo,
   *en una ubicacion.
   *En caso de que ubicacion sea vacia, milsl trabaja en el directorio
   *actual.
   *Si redireccion es verdadero, entonces la lista se pasa a guardar
   *en dat.
}

procedure milsl (ubicacion:string;redireccion:boolean);
begin
olddir:=midir;
ubi:=ubicacion;
cant_archivos:= 0;
crearlista(lis);
ttotal:=0;

if ubicacion <> ' ' then micd(ubicacion);

ubi:=midir;
dire:= fpOpenDir(ubi);

if dire<>nil then
      begin
      repeat
          entrada := fpReadDir(dire^);
          if entrada <> nil then
          begin
          	with entrada^ do
          	begin
                if copy(pchar(@d_name[0]),1,1)<>'.' then
                if fpLStat(pchar(@d_name[0]),archivo)=0  then
                begin
          				// permisos
          				aux.permisos:=GetFilePermissions(archivo.st_mode);
						// links
						aux.nlink:=archivo.st_nlink;
						// usuario
						aux.usuario:=GetUserName(archivo.st_uid);
						// grupo
						aux.grupo:=GetGroupName(archivo.st_gid);
              			// tamanio
						aux.tam:=archivo.st_size;
						// fecha de ultima modificacion
						D:=UnixToDateTime(archivo.st_ctime);
						DecodeDate (D,YY,MM,DD) ;
						DecodeTime (D,HH,MI, SS,MS) ;
						aux.fecha:=(meses[MM]+' '+dias[DD]+' '+numero[HH]+':'+numero[MI]);
						//color
						//ejecutables = verde claro
						if (not(fpS_ISDIR(archivo.st_mode))) and (STAT_IXUsr and archivo.st_mode=STAT_IXUsr) then
           					aux.color:=9
		          			else
				  		//Registro = blanco
		          		if fpS_ISREG(archivo.st_mode) then
		          			aux.color:=15
		          			else
			  			//link= celeste claro
			  	        if fpS_ISLNK(archivo.st_mode) then
		      				aux.color:=11
              				else
              			//Directorio = turquesa
						if fpS_ISDIR(archivo.st_mode) then
						aux.color:=3;
                end;

						//INFO AUX
						//clave
						aux.clave:=upCase(pchar(d_name));
						//nombre
						aux.nombre:=pchar(d_name);

				end;
				InsertarEnLista(lis,aux);
          end;
		  until entrada = nil;

	if redireccion then
	listadolR(lis,cant_archivos,ttotal)
	else
	listadol(lis,cant_archivos,ttotal);


	Str(cant_archivos,cant);
	Str(ttotal,total);
	devolverMensaje('Cantidad de archivos: ');
	devolverMensaje(cant);
	devolverMensaje(' Tamanio total: ');
	devolverMensaje(total);

	fpCloseDir (dire^);
end;


if ubi<> ' ' then
micd('-');
end;



{
   
   name: milsa
   @param
   * ubicacion : string
   * redireccion : boolean
   @return
   
   *El procedimiento milsa lista los elementos en formato corto,
   *en una ubicacion.
   *En caso de que ubicacion sea vacia, milsa trabaja en el directorio
   *actual.
   *Si redireccion es verdadero, entonces la lista se pasa a guardar
   *en dat.
}

procedure milsa (ubicacion:string;redireccion:boolean);

begin
	olddir:=midir;
	ubi:=ubicacion;
    cant_archivos:= 0;
    crearlista(lis);
    if  ubicacion<> ' ' then
    	micd(ubicacion);

    ubi:=midir;
    dire:= fpOpenDir(ubi);

	if dire<>nil then
	begin
		if redireccion then                 //con redir
		begin
		    repeat
			Entrada := fpReadDir(dire^);
			if Entrada<>nil then
		            with Entrada^ do
		         begin
		        	inc(cant_archivos);
		        	if fpStat(pchar(@d_name[0]),archivo)=0  then
		              begin
				   	aux.clave:=upCase(pchar(entrada^.d_name));  //clave
				   	aux.nombre:=pchar(entrada^.d_name);         //nombre
				   	InsertarEnLista(lis,aux);
		              end;
		         end;
			until entrada = nil;
		ListadoaR(lis);
		end
	else                                            //sin redir
	begin
		repeat
		entrada := fpReadDir(dire^);
		if entrada<>nil then
			with entrada^ do
			begin
			//si encuentra el nombre del archivo devuelve 0
				if fpLStat(pchar(@d_name[0]),archivo)=0  then
				begin
					inc(cant_archivos);
				    //el modo es ejecutable
					if (not(fpS_ISDIR(archivo.st_mode))) and (STAT_IXUsr and archivo.st_mode=STAT_IXUsr) then
					{verde claro}
					aux.color:=10
					else
					if fpS_ISREG(archivo.st_mode) then
					{blanco}
					aux.color:=15
					else
					if fpS_ISLNK(archivo.st_mode) then
					{celeste claro}
					aux.color:=11
					else
					if fpS_ISDIR(archivo.st_mode) then
					{azul claro}
					aux.color:=9;
			//clave
			aux.clave:=upCase(pchar(entrada^.d_name));
			//nombre
			aux.nombre:=pchar(entrada^.d_name);
			InsertarEnLista(lis,aux);
				end;
		    end;
		until entrada = nil;
	Listadoa(lis);
	end;
fpCloseDir (dire^);
end
else
devolverMensaje('Error en la lectura del directorio');


if ubi<> ' ' then
micd('-');
end;


{
   
   name: milsfR
   @param
   * ubicacion : string
   @return
   
   *El procedimiento milsfR guarda los elementos, de una ubicacion,
   *de formato corto en dat de manera no ordenada. 
   *En caso de que ubicacion sea vacia, milsfR trabaja en el directorio
   *actual.
}
procedure milsfR(ubicacion:string);
var lin,aux: string;
begin
olddir:=midir;
    ubi:=ubicacion;
    cant_archivos:= 0;
    if ubicacion<> ' ' then
       micd(ubicacion);

            ubi:=midir;
            dire:= fpOpenDir(ubi);
            if dire<>nil then
			begin
                repeat
                	entrada := fpReadDir(dire^);
                  	with entrada^ do
                    begin
                      	if entrada <> nil then
                        begin
                        	inc(cant_archivos);
                        	if fpStat(pchar(@d_name[0]),archivo)=0  then
                            begin
                            lin:=pchar(entrada^.d_name);
							//Completar(saux,256-length(saux));
							aux:=char(10);
                                     lin:=lin+aux;
                                     aux:=char(13);
                                     lin:=lin+aux;
							devolverMensajeA(lin);         //nombre
                            end;
                       	end;
                    end;
                until entrada = nil;
                Str(cant_archivos,cant);
                devolverMensaje('Cantidad de archivos: ');
		devolverMensaje(cant);
                fpCloseDir (dire^);
                end
           	else
           		devolverMensaje('Error en la lectura del directorio');

	if ubi<> ' ' then
	micd('-');
end;

{
   
   name: mipwd
   @param
   @return
   
   *Carga en la variable global dat la ruta del directorio actual.
}
procedure mipwd;
var
	lin,saux:string;
begin
	lin:=midir;
	saux:=char(10);
	lin:=lin+saux;
	saux:=char(13);
	lin:=lin+saux;
	devolverMensaje(lin);
end;


{
   
   name: mifg
   @param
   * P1 : string
   @return
   
   *Recibe P1 como PID a poner en primer plano.
   *Si encuentra el proceso en el registro de procesos activos entonces,
   *manda una señal de continuar ejecucion en primer plano.  
   
}
procedure mifg(P1: string);
var
cod: word;
apid,i: longint;
begin
    val(P1,apid,cod);
    if cod = 0 then
    begin
			for i:= Low(LJobs) to high(LJobs) do
			if LJobs[i].j_pid = apid then
				if AnsiContainsStr(LJobs[i].j_nombre,'&') then
					Setlength(LJobs[i].j_nombre,Pos('&',LJobs[i].j_nombre)-2);
	mikill(P1,'18');
	end;
end;

{
   
   name: micat
   @param
   @return
   
   * Lee los datos mediante la entrada estandar y la guarda en la
   * variable global dat.
}
procedure micat;
var
lectura: string;
begin
	SetLength(dat,0);
	readln(lectura);
	devolverMensaje(lectura);
end;

{
   
   name: micat1
   @param
   * arch1 : string
   @return
   
   *Lee los datos de arch1 y los guarda en dat. 
   
}
procedure micat1(arch1:string);
var  fd : Longint;
  i:longint ;
  archivo: Stat;
  infoarch:string;
begin
	SetLength(dat,0);
	if fpStat(arch1,archivo)=0 then
		begin
		    fd := fpOpen(arch1,O_RdOnly);
		    if fd>0 then
		    begin
		            setlength(infoarch, archivo.st_size);
		            for i:=1 to length(infoarch)-1  do
		            if  fpRead(fd,infoarch[i],length(infoarch)+1) < 0 then
		                    devolverMensaje('Error leyendo archivo!!!');
		            devolverMensaje(infoarch);
		    end
		    else
			devolverMensaje('Error al buscar el archivo');

		    fpClose(fd);
		end
		else
		devolverMensaje('Error al buscar el archivo');

end;

{
   
   name: micat2
   @param
   * arch1 : string
   * arch2 : string
   @return
   
   *Este procedimiento recurre a micat1 para leer desde un archivo y
   *devuelve a la salida estandar los datos del archivo respectivo. 
}

procedure micat2(arch1:string; arch2:string);
var
datos:ArrayChar;
begin
		micat1(arch1);
		setlength(datos,length(dat));
		datos:=dat;
		micat1(arch2);
		datos:=ConcatArray(datos,dat);
		setlength(dat,0);
		devolverDatos(datos);

end;

{
   
   name: mibg
   @param
   * P1 : string
   @return
   
   *Recibe P1 como PID a poner en segundo plano.
   *Si encuentra el proceso en el registro de procesos activos entonces,
   *manda una señal de continuar ejecucion en segundo plano.  
   
}
procedure mibg(P1: string);
var
cod: word;
pid,i: longint;
begin
    val(P1,pid,cod);
    if cod = 0 then
    begin
		mikill(P1,'18');
		for i:= Low(LJobs) to high(LJobs) do
			if (LJobs[i].j_pid = pid) and (AnsiContainsStr(LJobs[i].j_nombre,'&')=false)then
			LJobs[i].j_nombre := LJobs[i].j_nombre+' &';
	end;
end;

{
   
   name: mikill
   @param
   * S1 : string
   * S2 : string
   @return
   
   *Envia una señal a un proceso.
   * S1 representa el pid del proceso.
   * S2 representa la señal.
}

procedure mikill(S1: string; S2:string);
 var
    i: integer;
    code1,code2,P1,P2: word;
    begin
           setlength(dat,0);
           if (S1='-1') and (S2='-1') then
			devolverMensaje('El proceso necesita 2 parametros: pid del proceso - senial')
             else
             begin
               val(S1,P1,code1);
               val(S2,P2,code2);
                 if (code1 <> 0) and (code2 <> 0) then
                 devolverMensaje('Error en los parametros')
                 else
                 begin
                 i:=Low(Ljobs);
						while (i <= high(Ljobs)) and (LJobs[i].j_pid <> P1) do
						inc(i);
						if i > high(Ljobs) then
						devolverMensaje('PID inexistente')
						else
						begin
						Fpkill(P1,P2);
						case P2 of
							9: 	LJobs[i].j_estado:= 'Terminado';
							18: begin
										LJobs[i].j_estado:= 'Ejecutando';
										JIndex:=i;
								end;
							19:	LJobs[i].j_estado:= 'Detenido';
						
						end;
							devolverMensaje('Proceso ');
							devolverMensaje(LJobs[i].j_nombre);
							devolverMensaje(' ');
							devolverMensaje(LJobs[i].j_estado);
						end;
			end;
    end;
end;

{
   
   name: mijobs
   @param
   @return
   
   *Devuelve la lista de procesos activos por la salida estandar. 
   
}
procedure mijobs;
var i: integer;
Begin
    if length(LJobs)>0 then
	for i:=Low(LJobs) to length(LJobs)-1 do
	begin
	write('[',i,']');
	gotoxy(6,wherey);
	write(Ljobs[i].j_pid);
	gotoxy(12,wherey);
	write(Ljobs[i].j_estado);
	gotoxy(28,wherey);
	writeln(Ljobs[i].j_nombre);
	end;
End;

 end.
