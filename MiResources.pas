Unit MiResources;

Interface

Uses
        crt,keyboard,MiTypes,UnixType,Unix,strutils;

procedure devolverMensaje(str:string);
procedure devolverMensajeA(str:string);
procedure Completar(var str:string;num:word);
procedure devolverDatos(info:ArrayChar);
procedure mostrar(var datos: ArrayChar);
function ConstArray(a1:String ; a2:salida): salida;
function rutaPadre(ruta:string): string;
function verificarRuta(ruta:string): byte;
function GetFilePermissions(mode: mode_t): string;
function ConcatArray(a, b: ArrayChar): ArrayChar;
function devolverInterno(str:string): integer;

Implementation

{
   
   name: GetFilePermissions
   @param
   * mode: mode_t
   @return
   * string
   
   * Recibe un dato de tipo mode_t y devuelve un string que muestra
   * el tipo y los permisos del archivo para el usuario,
   * el grupo y otros.
   
}
function GetFilePermissions(mode: mode_t): string; // Recibe un dato de tipo mode_t y devuelve un string que muestra
         var                                                     // el tipo y los permisos del archivo para el usuario,el grupo y otros.
                Resultado: string;
    begin
           Resultado:='';

           if STAT_IFLNK and mode=STAT_IFLNK then    // file type
             Resultado:=Resultado+'l'
           else
           if STAT_IFDIR and mode=STAT_IFDIR then
             Resultado:=Resultado+'d'
           else
           if STAT_IFBLK and mode=STAT_IFBLK then
             Resultado:=Resultado+'b'
           else
           if STAT_IFCHR and mode=STAT_IFCHR then
             Resultado:=Resultado+'c'
           else
             Resultado:=Resultado+'-';


           if STAT_IRUSR and mode=STAT_IRUsr then    // user permissions
             Resultado:=Resultado+'r'
           else
             Resultado:=Resultado+'-';
           if STAT_IWUsr and mode=STAT_IWUsr then
             Resultado:=Resultado+'w'
           else
             Resultado:=Resultado+'-';
           if STAT_IXUsr and mode=STAT_IXUsr then
             Resultado:=Resultado+'x'
           else
             Resultado:=Resultado+'-';

           if STAT_IRGRP and mode=STAT_IRGRP then           // group permissions
             Resultado:=Resultado+'r'
           else
             Resultado:=Resultado+'-';
           if STAT_IWGRP and mode=STAT_IWGRP then
             Resultado:=Resultado+'w'
           else
             Resultado:=Resultado+'-';
           if STAT_IXGRP and mode=STAT_IXGRP then
             Resultado:=Resultado+'x'
           else
             Resultado:=Resultado+'-';

           if STAT_IROTH and mode=STAT_IROTH then    // other permissions
             Resultado:=Resultado+'r'
           else
             Resultado:=Resultado+'-';
           if STAT_IWOTH and mode=STAT_IWOTH then
             Resultado:=Resultado+'w'
           else
             Resultado:=Resultado+'-';
           if STAT_IXOTH and mode=STAT_IXOTH then
             Resultado:=Resultado+'x'
           else
             Resultado:=Resultado+'-';

           GetFilePermissions:=Resultado;


    end;





function ConstArray(a1:String ; a2:salida): salida;
var
i,r:integer;
resultado: salida;
begin
SetLength(resultado,High(a2)-Low(a2)+2);
r:=0;
resultado[r] := a1;
Inc(r);
for i := Low(a2) to High(a2) do begin
resultado[r] := a2[i];
Inc(r);
end;
ConstArray:=resultado;
end;

{
   
   name: Completar
   @param
   * str: string
   * num: word
   @return
    
   * Recibe un string y devuelve otro de longitud num, que posee el 
   * primero per que se completa con espacios (' ') hasta llegar al 
   * tamaño indicado Si el string que se le pasa tiene una longitud 
   * mayor a num devuelve el mismo
   
}

 procedure Completar(var str:string;num:word); 
     begin                                      
                while length(str)<num do                  
            begin
              str:=str+' ';
            end;
     end;


{
   
   name: devolverMensaje
   @param
   * str : string
   @return
   
	* Carga el mensaje de tipo string que se le pasa
	* a la variable global dat de tipo ArrayChar del shell
}
procedure devolverMensaje(str:string);
var i,j:word;
begin
           if High(dat) < 1 then
               begin
               i:=Low(dat);
               SetLength(dat,i+1);
           dat[i]:=#13;
               end
           else i:=High(dat)+1;
           for j:=1 to length(str)+1 do
                    begin
                 inc(i);
             SetLength(dat,i+1);
               dat[i]:=str[j];
             end;
               SetLength(dat,High(dat));
     end;


procedure devolverMensajeA(str:string);
var i,j:word;
begin
           if High(dat) < 1 then
               begin
               i:=Low(dat);
               SetLength(dat,i+1);
           dat[i]:=#13;
               end
           else i:=High(dat)+1;
           for j:=1 to length(str) do
                    begin
                 inc(i);
             SetLength(dat,i+1);
               dat[i]:=str[j];
             end;
               SetLength(dat,High(dat));
     end;

{
   
   name: devolverDatos
   @param
   * info: ArrayChar
   @return
   
   * Carga el mensaje de tipo ArrayChar que se le pasa en la variable 
   * global dat del mismo tipo del shell
   
}

procedure devolverDatos(info:ArrayChar);  // Carga el mensaje de tipo ArrayChar que se le pasa en la variable global
     var i,j:word;                                   // dat del mismo tipo del shell
     begin
     i:=Low(dat);
           if High(dat)<1 then
            begin
               SetLength(dat,i+1);
               inc(i);
                 end
           else i:=High(dat)+1;
           j:=low(info);
           while (j <= High(info)) do
                    begin
               SetLength(dat,i+1);
               dat[i]:=info[j];
               inc(i);
               inc(j);
             end;
               SetLength(dat,High(dat));
     end;

{
   
   name: mostrar
   @param
   * datos: ArrayChar
   @return
   
   * El procedimiento muestra en pantalla el contenido de la variable
   * 'datos' de tipo ArrayChar que se le pasa
   
}
procedure mostrar(var datos: ArrayChar);   
var  i: word;
begin
            if High(datos)>0 then
                  begin
                    for i:=low(datos)  to High(datos) do
                      Write(datos[i]);
                  end;
            Write(#10);
            Write(#13);
SetLength(datos,0);
end;
{
   
   name: rutaPadre
   @param
   * ruta: string
   @return
   * Recibe un string que posea '/' y devuelve otro en el cual ha 
   * eliminado el postfijo que sigue a la ultima ocurrencia de '/'
   
}
function rutaPadre(ruta:string): string;         
            begin                                            
              while copy(ruta,length(ruta),length(ruta)) <> '/' do
            ruta:=copy(ruta,1,length(ruta)-1);
              rutaPadre:=copy(ruta,1,length(ruta)-1);
    end;
{
   
   name: verificarRuta
   @param
   * ruta: string
   @return
   * byte
   
   * Verifica que el string que se le pasa sea una ruta de 
   * directorio valida.
   
}
function verificarRuta(ruta:string): byte;   
begin
              {$I-}
              ChDir (ruta);
              if IOresult<>0 then
                verificarRuta:=0
      else
                verificarRuta:=1;
    end;
{
   
   name: ConcatArray
   @param
   * a: ArrayChar
   * b: ArrayChar
   @return
   * arreglo de caracteres
   
   * concatena los arreglos a y b.
   
}

function ConcatArray(a, b: ArrayChar): ArrayChar;
var i: Longint;
begin
SetLength(ConcatArray, Length(a) + Length(b));
for i := 0 to High(a) do
ConcatArray[i] := a[i];
for i := 0 to High(b) do
ConcatArray[i + Length(a)] := b[i];
end;



function devolverInterno(str:string): integer;
var
indice: integer;
buscado:boolean;
Begin
	indice:= 1;
	buscado:=false;
while (buscado=false) and (AnsiContainsStr(Entrada,comandos[indice])=false)do
		begin
		buscado:= (indice>=(length(comandos)));
		inc(indice);
		end;
if (not buscado) then
devolverInterno:=indice
else
devolverInterno:=-1;
End;





Begin
End.
