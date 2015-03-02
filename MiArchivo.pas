unit MiArchivo;

interface

Uses
	crt,sysutils,MiTypes,MiResources,BaseUnix,strutils;

function abrirArchivo(arch:string): Longint;
procedure escribirArchivo(arch:string;var datos: ArrayChar);
procedure reEscribirArchivo(arch:string;var datos: ArrayChar);

implementation

{
   
   name: abrirArchivo
   @param
   * arch : string
   @return
   * Longint
   
   *Abre un archivo de nombre 'arch' y devuelve su descriptor.
   
}

function abrirArchivo(arch:string): Longint;
Var fd : Longint;
begin
        fd := FPOpen(arch,O_WrOnly OR O_Creat);
               if fd < 0 then
               devolverMensaje('Error al abrir el archivo')
           else
                if FpFtruncate(fd,0)<>0 then
                begin
                fd:=-1;
                   devolverMensaje('Error al reiniciar el archivo');
                end;
                abrirArchivo:=fd;
end;

{
   
   name: escribirArchivo
   @param
   * arch : string
   * datos : ArrayChar
   @return
   
   * Guarda los datos que se le pasan en la variable datos de tipo 
   * ArrayChar en el archivo de nombre arch.
   * Si el archivo no existe lo crea y si existe escribe los datos 
   * al final.
   
}


procedure escribirArchivo(arch:string;var datos: ArrayChar);

Var
    fd : Longint;
    i:word;

begin
    fd := FPOpen(arch,O_WrOnly OR O_Creat);
    if fd < 0 then
    devolverMensaje('Error al abrir el archivo')
    else
    if fpLSeek(fd,0,Seek_end)=-1 then
    devolverMensaje('Error al posicionarse en el archivo')
            else
                     begin
                               if (Length(datos)-1) >0 then
                                    for i:=Low(datos) to Length(datos)-1 do
                                           if (FPWrite(fd,datos[i],1))=-1 then
                                            devolverMensaje('Error al escribir en el archivo');
                                      FPClose(fd);
                                       SetLength(datos,0);
                     end;
end;

{
   
   name: reEscribirArchivo
   @param
   * arch : string
   * datos : ArrayChar
   @return
   
   * Guarda los datos que se le pasan en la variable datos de tipo 
   * ArrayChar en el archivo de nombre arch.
   * Si el archivo no existe lo crea y si existe lo sobreescribe.
   
}

procedure reEscribirArchivo(arch:string ;var datos: ArrayChar);

Var
        fd: Longint;
        i:word;
        st:string;
begin


       fd := FPOpen(arch,O_WrOnly OR O_Creat);
       if fd > 0 then
		begin
			if FpFtruncate(fd,0)=0 then
                begin
                SetLength(st,sizeof(datos));
					for i:=Low(datos) to length(datos)-1 do
					begin
					st:=datos[i];
						if (length(st)+1<> fpwrite(fd,st[1],length(st))+1) then
						devolverMensaje('Error al escribir en el archivo');
					end;
					FPClose(fd);
				end
				else
                devolverMensaje('Error al reiniciar el archivo');
		end
		else
        devolverMensaje('Error al abrir el archivo');
end;

end.

