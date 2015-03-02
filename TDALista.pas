unit TDALista;
interface
             uses
                   crt,MiResources,MiTypes;

             type   T_DATOL= record
                            clave:string;
                            nombre:string;
                            color:byte;
                            permisos:string;
                            nlink:byte;
                            usuario:string;
                            grupo:string;
                            tam:longint;
                            fecha:string;
                   end;

                    T_PUNTEROL= ^T_NODOL;

                    T_NODOL= Record
                               Info: T_DATOL;
                               Siguiente: T_PUNTEROL;
                            end;

                    T_LISTA= Record
                               Cabecera: T_PunteroL;
                               Tamanio: Cardinal;
                            end;

procedure CrearLista(var L:T_LISTA);    // Crea una lista dinamica vacía y la devuelve en la variable L

procedure InsertarEnLista(var L:T_LISTA; x:T_DATOL);// Inserta ordenadamente el elemento que recibe en la variable x, en la lista L

procedure Listadoa(var L:T_LISTA);    // Realiza un listado de los datos de la lista con el formato del comando ls -a

procedure ListadoaR(var L:T_LISTA);  //Guarda en la variable global dat el contenido de la lista

procedure Listadol(var L:T_LISTA;var cant:longint;var total:longint);// Realiza un listado de los datos de la lista con el
                                                                    // formato del comando ls -l
procedure ListadolR(var L:T_LISTA;var cant:longint;var total:longint);



implementation



procedure CrearLista(var L:T_LISTA);
                       begin
                         L.cabecera:=nil;
                         L.tamanio:=0;
                       end;

procedure InsertarEnLista(var L:T_LISTA; x:T_DATOL);
                      var Ant,Act,DirAux: T_PUNTEROL;
                      begin
                        new(DirAux);
                        DirAux^.Info:=x;
                        if (L.cabecera=nil) or (L.cabecera^.info.clave>x.clave) then
                          begin
                            DirAux^.siguiente:=L.cabecera;
                            L.cabecera:=DirAux;
                          end
                        else
                          begin
                            Ant:=L.cabecera;
                            Act:=L.cabecera^.siguiente;
                            while (Act<>nil) and (Act^.info.clave<=x.clave) do
                              begin
                                ant:=act;
                                act:=act^.siguiente
                              end;
                              diraux^.siguiente:=act;
                            ant^.siguiente:=diraux;
                          end;
                        Inc(L.tamanio);
                      end;

procedure Listadoa(var L:T_LISTA);
                      var Act: T_PUNTEROL;
                      i:integer;
                      begin
                      i:=0;
                         act:=L.cabecera;
                         while (Act<>nil) do
                           begin
                               with Act^.info do
                             		begin
                            		textcolor(color);
                                 	writeln(nombre);
                                 	end;
                             Act:=Act^.siguiente;
                             inc(i);
                           end;
                         textcolor(15);
                      end;

procedure Listadol(var L:T_LISTA;var cant:longint;var total:longint);
                      var Act: T_PUNTEROL;
                      begin
                         act:=L.cabecera;
                         while (Act<>nil) do
                           begin
                               with Act^.info do
                             begin
                            if copy(nombre,1,1)<>'.' then
                              begin
                                         textcolor(15);
                                     write(permisos);
                                     gotoxy(12,WhereY);
                                     write(nlink);
                                     gotoxy(14,WhereY);
                                     write(usuario);
                                     gotoxy(22,WhereY);
                                     write(grupo);
                                     gotoxy(30,WhereY);
                                     write(tam:7);
                                     gotoxy(38,WhereY);
                                     write(fecha);
                                     gotoxy(52,WhereY);
                                     textcolor(color);
                                     writeln(nombre);
                                     inc(cant);
                                     total:=total+tam;
                              end;
                                 end;
                             Act:=Act^.siguiente;
                           end;
                         textcolor(15);
                      end;
procedure ListadolR(var L:T_LISTA;var cant:longint;var total:longint); //Guarda en la variable global dat el contenido de la lista
                      var Act: T_PUNTEROL;                                      // y devuelve la cantidad de archivos y el tamaño total
                      lin,aux:string;
                      begin
                         act:=L.cabecera;
                         while (Act<>nil) do
                           begin
                               with Act^.info do
                             begin
                            if copy(nombre,1,1)<>'.' then
                              begin
									nombre:=nombre;
                                     lin:=permisos;
                                     Completar(lin,12);
                                     Str(nlink,aux);
                                     lin:=lin+aux;
                                     Completar(lin,14);
                                     lin:=lin+usuario;
                                     Completar(lin,22);
                                     lin:=lin+grupo;
                                     Completar(lin,30);
                                     Str(tam,aux);
                                     Completar(lin,37-length(aux));//para que el num quede alineado a la derecha
                                     lin:=lin+aux;
                                     Completar(lin,38);
                                     lin:=lin+fecha;
                                     Completar(lin,52);
                                     lin:=lin+nombre;
                                     //Completar(lin,256-length(lin));
                                     aux:=char(10);
                                     lin:=lin+aux;
                                     aux:=char(13);
                                     lin:=lin+aux;
                                     inc(cant);
                                     total:=total+tam;
                                     
                                     devolverMensaje(lin);
                              end;
                                 end;
                             Act:=Act^.siguiente;
                           end;
                      end;

procedure ListadoaR(var L:T_LISTA);//Guarda en la variable global dat el contenido de la lista
var Act: T_PUNTEROL;
saux,lin:string;
begin
        act:=L.cabecera;
        while (Act<>nil) do
        begin
                with Act^.info do
                begin

						lin:=nombre;
					    saux:=char(10);
                        lin:=lin+saux;
                        saux:=char(13);
                        lin:=lin+saux;
					    //Completar(saux,256-length(nombre));
                        devolverMensajeA(lin);
                end;
                act:=Act^.siguiente;
        end;
        textcolor(15);
end;


end.
