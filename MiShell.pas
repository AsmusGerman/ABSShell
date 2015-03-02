{Copyright (C) 2015  Asmus - Bouvier - Segovia
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.

}

Program MiShell;

Uses
crt,strutils,SysUtils,MacroUtils,BaseUnix,Unix,MiTypes,MiResources,MiArchivo, MiUtils;

var
indice: integer;

Begin

Clrscr;
iniciarvariables;
prompt;
micd('.');
Readln(Entrada);

while Entrada<>'exit' do
	begin
	analizarEntrada(Entrada);
	indice:=devolverInterno(Entrada);
	if indice <> -1 then
	Lanzador(indice)
	else
	begin
		bbg := AnsiContainsStr(Entrada,'&');
		if bbg = true then
		setlength(Entrada,Pos('&',Entrada)-2);
		
		initSignal;	
		pid := fpFork;
		case pid of
			-1 : devolverMensaje('Error al iniciar el proceso externo');
			 0 : lanzarExterno(Entrada);
			else
			begin
					
					
					if (bpipe) and (Entrada2=' ') then
						begin
						fpClose(atras);
						fpClose(frente);
						bpipe:=false;
						end;
					guardarProceso(Entrada,pid);
					JIndex:=High(LJobs);
					waitshell;
			end;
		end;
	actualizarJobs;
	end;
	
	analizarSalida(Entrada2);
	
		if(Entrada2=' ') and (not bpipe)then
		begin
		sleep(100);
		mostrar(dat);
		prompt;
		Readln(Entrada);
		end;


	end;
	Writeln('Ha salido de ABS-Shell');

end.
