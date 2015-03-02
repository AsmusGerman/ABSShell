Unit MacroUtils;
interface

Uses
 MiUtils, MiArchivo, MiTypes, MiResources, BaseUnix, Unix, crt,
 strutils, SysUtils, DateUtils, users, unixutil, TDALista, keyboard;


procedure iniciarvariables;
procedure prompt;
procedure analizarEntrada(str: string);
procedure analizarSalida(pEntrada2: string);
function Descifrador(str: string; separator: string): salida;
procedure Lanzador (i : integer);
procedure lanzarExterno(pEntrada: string);
procedure guardarProceso(pEntrada: string; pPid: integer);
procedure waitshell;
procedure actualizarJobs;
procedure aPipe;
procedure dPipe;
procedure initSignal;

Implementation

{
	name: iniciarvariables;
	@param
	@return
	
	* El procedimiento inicializa las variables globales definidas en
	* la unit MiTypes para su uso deliberado en ABS-Shell
}
 procedure iniciarvariables;
 begin
        home:='/home';
        olddir:=home;
        usuarioActual:=fpgetenv('USER');
        hostActual:=gethostname;
        homeMasUsuarioActual:=(home+'/'+usuarioActual);
        midir:=homeMasUsuarioActual;
        Entrada2:=' ';
        SetLength(LJobs,0);
        jIndex:=-1;
        bpipe:=false;
 end;


{

   name: prompt
   @param
   @return

   * El procedimiento se encarga de mostrar el prompt
   * en la salida estandar.

}

Procedure prompt;
Begin
	write(usuarioActual,'@','-',hostActual,':');
	if copy(midir,1,length(homeMasUsuarioActual)) = homeMasUsuarioActual then
		write('~',copy(midir,length(homeMasUsuarioActual)+1,length(midir)))
	else
		write(midir);
	
	if (usuarioActual = 'root') then
		write('# ')
	else
		write('$ ');
end;

{

   name: analizarEntrada
   @param
   * str : string
   @return

   * Se analiza la variable str en busca de un caracter especial y su
   * posicion. En caso de existir alguno, se procede a dividir str
   * según la posicion de la primera ocurrencia de dicho caracter.
   * Todos los caracteres de posicion menor a la posicion del caracter
   * especial son asignados a la variable Entrada.
   * Todos los caracteres desde la posicion del caracter especial
   * (incluido) hasta el final de str se asignan a la variable Entrada2.

}
procedure analizarEntrada(str: string);
     var i,j:integer;
     begin
           i:=pos('|',str);
           j:=pos('>',str);
           if (i>0) or (j>0) then
                 begin
                   if ((i<j) and (i<>0)) or (j=0) then
                   begin
						Entrada:=copy(str,1,i-2);
						Entrada2:=copy(str,i,length(str));
							if assignpipe(frente,atras)<>0 then
							devolverMensaje('Error creando pipe')
							else
							bpipe:=true;
                   end
                   else
                     if ((j<i) and (j<>0)) or (i=0) then
                       begin
                     Entrada:=copy(str,1,j-2);
                     Entrada2:=copy(str,j,length(str));
                     end;
                 end
           else
           begin
           Entrada:=str;
           Entrada2:=' ';
           end;
     end;

{

   name: analizarSalida
   @param
   * pEntrada2 : string
   @return

   *El procedimiento recibe la siguiente orden a ejecutar como
   *pEntrada2,con la precondicion: pEntrada2 siempre distinto de vacio.
   *Analiza el parametro y responde a la busqueda de simbolos especiales
   *como: |, >>, > .
   *Al finalizar actualiza las variables Entrada y Entrada2.

}
procedure analizarSalida(pEntrada2: string);
var
i:integer;
e:string;
begin

if pEntrada2 <> ' ' then
begin

	if copy(pEntrada2,1,1)='|' then
	begin
		if devolverInterno(Entrada) <> -1 then
		begin	
			if High(dat)>0 then
			begin
				for i:=low(dat) to High(dat) do
					fpWrite(atras,dat[i],1);			
			setlength(dat,0);
			fpclose(atras);
			end;
		end;
		analizarEntrada(copy(pEntrada2,3,length(pEntrada2)));
	end
		else if (copy(pEntrada2,1,2)='>>') then	
		begin
			e:=Entrada;
			analizarEntrada(copy(pEntrada2,4,length(pEntrada2)));
			if devolverInterno(e) <> -1 then
			begin
			escribirArchivo(copy(pEntrada2,4,length(pEntrada2)),dat);
			setlength(dat,0);
			end;
	end
		else if (copy(pEntrada2,1,1)='>') then
		begin
				if devolverInterno(e) <> -1 then
				begin
				reEscribirArchivo(copy(pEntrada2,3,length(pEntrada2)),dat);
				setlength(dat,0);
				end;
		end;
end
	else
	begin
		if (bpipe) and (devolverInterno(Entrada) <> -1) then
		begin	
			setlength(dat,0);
			for i:=low(dat) to High(dat) do
			fpRead(frente,dat[i],1);			
			
			fpclose(frente);
		end;
	end;
	analizarEntrada(copy(pEntrada2,3,length(pEntrada2)));
end;

{

   name: Descifrador
   @param
   * str : string
   * separator : string
   @return
   * Arreglo de cadenas de caracteres

   * La funcion genera un arreglo de cadenas de caracteres obtenidos
   * mediante la separación indicada por el parametro separador.
   * Por ejemplo:
   * 	Descifrador('mils -l';' ');
   *
   * En el ejemplo la funcion devolvería un arreglo de longitud dos. El
   * primer elemento con 'mils' y el segundo con '-l'.

}

function Descifrador(str: string; separator: string): salida;
var
        resultado: salida;
begin
SetLength(resultado,1);
if Pos(separator, str) > 0 then
	resultado:= ConstArray(Copy(str, 1, Pos(separator, str) - 1),
	Descifrador(Copy(str,Pos(separator, str)+1,Length(str)),' '))
         else
         resultado[Low(resultado)]:= str;
         Descifrador:=resultado;
end;

{

   name: Lanzador
   @param
   * i: integer
   @return

   * El parametro i representa el comando interno a lanzar.
   * Por ejemplo si i = 1 representa mils -l.
   * A la variable Entrada la transforma en un vector, si existe ' '
   * la longitud del vector sera 2, de manera que
   * en la primera posicion se ecuentra el numero del comando
   * y en la segunda la ruta a la cual se quiere aplicar dicho comando.
   * si no existe ' ', la longitud del vestor sera 1, significa que el
   * comando se aplicara en el directorio actual.
   * en el caso de que exista algun simbolo especial,
   *realiza la operacion correspondiente.

}
procedure Lanzador(i : integer);
var
	clave: salida;
    begin

		clave:=Descifrador(Entrada,' ');
		case i of
//mils -l
		1 :begin
			if (Copy(Entrada2,1,1) = '>' )  or (Copy(Entrada2,1,1) = '|') then
			begin
				case  High(clave) of
                    1:milsl(' ',true);
                    2:milsl(clave[2],true);
				end;
			end
			else
			
			case High(clave) of
                    1:milsl(' ',false);
                    2:milsl(clave[2],false);
                    end;

                end;
//mils -a
             2 :begin
			 	if (Copy(Entrada2,1,1) = '>')  or (Copy(Entrada2,1,1) = '|')  then
					case High(clave) of
				    1:milsa(' ',true);
				    2:milsa(clave[2],true);
				    end
				else
					case High(clave) of
					1:milsa(' ',false);
                    2:milsa(clave[2],false);
                    end;
                end;
//mils -fR
             3 :begin
			 	if (Copy(Entrada2,1,1) = '>')  or (Copy(Entrada2,1,1) = '|')  then
					case   High(clave) of
				    1:milsfR(' ');
				    2:milsfR(clave[2]);
				    end;
                end;
//micat
			 4 :	case High(clave) of
                    0:micat;
                    1:micat1(clave[1]);
                    2:micat2(clave[1],clave[2]);
                    end;
//micd
			 5 :	case  High(clave) of
                    0:  micd(' ');
                    1:  micd(clave[1]);
                    end;
//mipwd
             6 :	mipwd;
//mikill
			 7 :	case High(clave) of
                    0:mikill('-1','-1');
                    1:mikill(clave[1],'-1');
	                2:mikill(clave[1],clave[2]);
                    end;
//mibg
			8 :	case High(clave) of
                    0:  mibg('-1');
                    1:  mibg(clave[1]);
                    end;
//mifg
			9 : 	begin
						case High(clave) of
						0:  mifg('-1');
						1:  mifg(clave[1]);
						end;
						mostrar(dat);
					waitshell;
					end;
//mijobs
			10 :    mijobs;

		end;
end;

{

   name: lanzarExterno
   @param
   * pEntada: string
   @return

   *Lanza un programa externo que se le pasa como string.
   *en el caso de que exista algun simbolo especial,
   *realiza la operacion correspondiente.

}


procedure aPipe;
begin
Fpclose(1);
fpdup(atras);
fpClose(frente);
fpClose(atras);
end;

procedure dPipe;
begin
Fpclose(0);
Fpdup(frente);
fpClose(atras);
fpClose(frente);
end;

Procedure DoSig (sig : cint); cdecl;
begin
	chterm:=false;
end;

procedure initSignal;
begin
	chterm:=true;
	new (na);
	na^.sa_handler:=sigActionHandler(@DoSig);
	fillchar(na^.Sa_Mask,sizeof(na^.sa_mask),#0);
	na^.sa_flags:=SA_RESTART or SA_NOCLDSTOP or SA_NOCLDWAIT;
	na^.Sa_Restorer:=nil;
end;

procedure lanzarExterno(pEntrada: string);
var
programa: string;
PP: PPchar;
begin
           programa:='cd '+midir+'; '+pEntrada;
           PP:=CreateShellArgV(programa);
           programa:=PP[0];

		  if Entrada2<>' ' then
           begin
				if copy(Entrada2,1,1) = '|' then aPipe
				
				else if copy(Entrada2,1,2) = '>>' then
					begin
						if abrirArchivo('Salida.txt')< 0 then
							devolverMensaje ('Error en el archivo!!!');
						
						micat1('Salida.txt');
						escribirArchivo(copy(Entrada2,4,length(Entrada2)),dat);
						DeleteFile('Salida.txt');
						analizarEntrada(copy(Entrada2,4,length(Entrada2)));
					 end
				else if copy(Entrada2,1,1)='>' then
					  begin
						if abrirArchivo(copy(Entrada2,3,length(Entrada2)))< 0 then
							devolverMensaje ('Error en el archivo!!!');
						analizarEntrada(copy(Entrada2,3,length(Entrada2)));
					  end;
			end
			else if bpipe=true then dPipe;
				
fpExecvp(programa, PP);
end;

{

   name: guardarProceso
   @param
   * pEntrada: string
   * pPid: integer
   @return

   *ABS-Shell guarda los procesos externos en un vector de registros.
   *Cada uno de los registros mantienen el nombre, el pid y el estado
   *del proceso en ejecucion.

}

procedure guardarProceso(pEntrada: string; pPid: integer);
Begin
setlength(Ljobs,length(Ljobs)+1);
	with job do
	begin
		j_pid:=pPid;
		j_estado:='Ejecutando';
		if bbg then
			j_nombre:=pEntrada+' &'
		else
			j_nombre:=pEntrada;
	end;
Ljobs[high(Ljobs)]:=job;
End;

{

   name: waitshell
   @param
   @return

   *Este procedimiento impide al shell seguir el curso de la ejecucion
   *normal, siempre que se ejecute un proceso externo en primer plano y
   *hasta que el usuario genere una interrupcion mediante las teclas
   *de funcion: Supr, Inicio, RePag, AvPag, Fin.

}

procedure waitshell;
var
 k : TKeyEvent;
 saux : string;
 boo : boolean;

begin
InitKeyBoard;

boo:=true;

while (chterm) and (boo) and (not bbg) and (copy(Entrada2,1,1)<>'>')
and  (copy(Entrada2,1,2)<>'>>') do

begin

if fpSigAction(SIGCHLD,na,nil) <> 0 then
devolverMensaje('Error de ejecucion en el proceso externo');


K:=PollKeyEvent;
if k<>0 then
	begin
	k := GetKeyEvent;
	k := TranslateKeyEvent(K);
		case k of
		11544: 						
			begin
			str(LJobs[JIndex].j_pid,saux);
			mikill(saux,'19');
			boo:=false;
			end;
		11779:						
			begin
			str(LJobs[JIndex].j_pid,saux);
			mikill(saux,'9');
			boo:=false;
			end;
		50367744:
			begin
			str(LJobs[JIndex].j_pid,saux);
			mikill(saux,'19');
			if JIndex = Low(LJobs) then
				JIndex:= High(LJobs)
				else
				dec(JIndex);
			
			mostrar(dat);

			str(LJobs[JIndex].j_pid,saux);
			mifg(saux);

			mostrar(dat);

			mijobs;
			end;
		50368768:
			begin
			str(LJobs[JIndex].j_pid,saux);
			mikill(saux,'19');
			if JIndex = High(LJobs) then
				JIndex:= Low(LJobs)
				else
				inc(JIndex);
			
			mostrar(dat);

			str(LJobs[JIndex].j_pid,saux);
			mifg(saux);

			mostrar(dat);

			mijobs;
			end;
		3849:
			begin
			str(LJobs[High(Ljobs)].j_pid,saux);
			mibg(saux);
			break;
			end;		
		end;
	end;
end;
DoneKeyboard;
end;

{

   name: actualizarJobs
   @param
   @return

   *El procedimiento invocado genera un cambio en el vector de procesos
   * activos. Si encuentra un proceso en estado 'Terminado' procede a
   * eliminarlo.

}
procedure actualizarJobs;
Var i,j:integer;
Begin

if not (chterm) then
	LJobs[High(LJobs)].j_estado:= 'Terminado';

for i:= Low(LJobs) to Length(LJobs)-1 do
 if LJobs[i].j_estado= 'Terminado' then
    Begin
        for j:=i to Length(LJobs)-1 do
        if j<Length(LJobs)-1 then
        LJobs[j]:=LJobs[j+1]
        else
        setLength(LJobs,Length(LJobs)-1);
    end;
end;

END.
