function [ g, r, gc ] = imhawkeye( imfile, matchtype, playerside, shottype, varargin )
%IMHAWKEYE Procesa una imagen de captura de cámara de alta precición de
%una cancha de tenis (vista desde arriba) y determina si el punto fue válido o no (IN, OUT); 
%de acuerdo a las reglas del tenis.
%
%   [ G, R ] = IMHAWKEYE( IMFILE, MATCHTYPE, PLAYERSIDE, SHOTTYPE, SERVICEDIR) 
%   Dada una imagen que representa la cancha de tenis y el pique de la
%   pelota en la misma IMFILE, determina de acuerdo a la información provista en
%   los parámetros restantes si el tiro fue válido o no (IN, OUT). 
%   Los parámetros de la IMHAWEYE son los siguientes:
%   * IMFILE - nombre del archivo de imagen a procesar. Debe ser una imagen
%   en formato tif
%   * MATCHTYPE - ['SINGLES' | 'DOUBLES'`] tipo de partido 
%   * PLAYERSIDE - ['LEFT' | 'RIGHT'] dirección de ataque del jugador
%   * SHOTTYPE - ['SERVICE' | 'SHOT'] si se trata de un saque o un punto iniciado 
%   * SERVICEDIR - ['LEFT' | 'RIGHT'] dirección del saque (solo tiene sentido si SHOTTYPE = 'SERVICE')
%
%   Retorna 
%       g = imagen original procesada
%       r = 'IN' si es un punto válido y 'OUT' en caso contrario
%       gc = imagen recortada detalle del pique de la pelota. Igual a g si
%       no hay ninguna pelotita en cancha

%registro global para las diferentes settings y parametros utilizados en la
%función
global IMG_SETTINGS;    
IMG_SETTINGS = struct();

IMG_SETTINGS.show_steps = 1;    %muestra las imagenes parciales generadas
IMG_SETTINGS.pause_steps = 1;   %pausa la ejecución luego de mostrar cada imagen parcial
IMG_SETTINGS.close_end = 1;     %cierra la vista de resultados al finalizar el análisis.
                                %Solo tiene utilidad si IMG_SETTINGS.show_steps = 1

IMG_SETTINGS.valid_width = 2048;            %ancho esperado de la imagen
IMG_SETTINGS.valid_height = 1024;           %alto esperado de la imagen
IMG_SETTINGS.valid_court_line_width = 10;   %tamaño esperado para las lineas de la cancha en pixels
IMG_SETTINGS.valid_regions_count = 11;      %cantidad de regiones esperadas para determinar si la imagen
                                            %tiene una cancha de tenis valida

%tamaño del square utilizado para borrar las líneas de la cancha que no
%pertenecen al área de interes a evaluar
IMG_SETTINGS.strel_court_line_size = IMG_SETTINGS.valid_court_line_width + 2;

%parametros para la función imfindcircles para detectar la pelotita de
%tenis
IMG_SETTINGS.find_circles_radius_range = [10 15];
IMG_SETTINGS.find_circles_sensitivity = 0.95;
IMG_SETTINGS.find_circles_object_polarity = 'bright';

%regiones de interes de la cancha de tenis según los parámetros de la función
%se recuperan luego de haber validado tanto los parámetros como la
%existencia de una cancha válida en la imagen a procesar
IMG_SETTINGS.('SINGLES').('LEFT').('SHOT') = [8 9 11];
IMG_SETTINGS.('SINGLES').('LEFT').('SERVICE').('LEFT') = 8;
IMG_SETTINGS.('SINGLES').('LEFT').('SERVICE').('RIGHT') = 9;
IMG_SETTINGS.('SINGLES').('RIGHT').('SHOT') = [3 5 6];
IMG_SETTINGS.('SINGLES').('RIGHT').('SERVICE').('LEFT') = 6;
IMG_SETTINGS.('SINGLES').('RIGHT').('SERVICE').('RIGHT') = 5;
IMG_SETTINGS.('DOUBLES').('LEFT').('SHOT') = [7 8 9 10 11];
IMG_SETTINGS.('DOUBLES').('LEFT').('SERVICE').('LEFT') = 8;
IMG_SETTINGS.('DOUBLES').('LEFT').('SERVICE').('RIGHT') = 9;
IMG_SETTINGS.('DOUBLES').('RIGHT').('SHOT') = [2 3 4 5 6];
IMG_SETTINGS.('DOUBLES').('RIGHT').('SERVICE').('LEFT') = 6;
IMG_SETTINGS.('DOUBLES').('RIGHT').('SERVICE').('RIGHT') = 5;

% Imagenes auxiliares utilizadas en la muestra final del resultado
IMG_SETTINGS.('IN') = imread('imgs/IN.jpg');
IMG_SETTINGS.('OUT') = imread('imgs/OUT.jpg');
IMG_SETTINGS.('ERROR') = imread('imgs/ERROR.jpg');

% registro global para almacenar la información de la imagen a medida que
% se avanza en su analisis
global IMG_DATA;
IMG_DATA = struct();

clc;
fprintf('IMHAWKEYE v1.0 - Author: Carlos Sebastián Castañeda\n\n');

fprintf('Validating arguments...\n');

fprintf('Validating imfile...\n');
validateattributes(imfile,{'char'},{'nonempty'},mfilename,'IMFILE',1);
[~,~,e] = fileparts(imfile);
if ~strcmpi(e, '.tif')
    error('Invalid file format! Only TIF images are valid.');
end
if exist(imfile, 'file') ~= 2
    error('Image file: %s does not exist!', imfile);
end

fprintf('Validating matchtype...\n');
validateattributes(matchtype,{'char'},{'nonempty'},mfilename,'MATCHTYPE',2);
values = {'SINGLES','DOUBLES'};
if ~strcmp(matchtype, values)
    error('Invalid value for MATCHTYPE. Posible values %s %s', values{:});
end

fprintf('Validating playerside...\n');
validateattributes(playerside,{'char'},{'nonempty'},mfilename,'PLAYERSIDE',3)
values = {'LEFT','RIGHT'};
if ~strcmp(playerside, values)
    error('Invalid value for PLAYERSIDE. Posible values %s %s', values{:});
end

fprintf('Validating shottype...\n');
validateattributes(shottype,{'char'},{'nonempty'},mfilename,'SHOTTYPE',3)
values = {'SERVICE','SHOT'};
if ~strcmp(shottype, values)
    error('Invalid value for SHOTTYPE. Posible values %s %s', values{:});
end

if strcmp(shottype, 'SERVICE')
    fprintf('Validating servicedir...\n');
    nVarargs = length(varargin);
    if nVarargs < 1
        error('Invalid number of arguments! SHOTTYPE is not especified');
    elseif nVarargs > 1
        error('Invalid number of arguments! Only SHOTTYPE must be especified');
    end
   
    servicedir = varargin{1};
    validateattributes(servicedir,{'char'},{'nonempty'},mfilename,'SERVICEDIR',5);
    values = {'LEFT','RIGHT'};
    if ~strcmp(servicedir, values)
        error('Invalid value for SERVICEDIR. Posible values %s %s', values{:});
    end
end
fprintf('Argument validation DONE!\n');

fprintf('Opening image file: %s...\n', imfile);
f = imread(imfile);

fprintf('Processing image...\n');

fprintf('Deleting alpha channel!\n');
f = f(:,:,1:3);
g = f;

params = sprintf('IM-HAWK-EYE | FILE: %s | PARAMS: %s - %s - %s - %s', imfile, matchtype, playerside, shottype, cell2str(varargin));
fprintf('PARAMS: %s \n', params);
if IMG_SETTINGS.show_steps 
    figure('Name',params,'NumberTitle','off','units','normalized','outerposition',[0 0 1 1]); 
end;

stopit_show(f, 'Original image (without alpha channel)', 232);

fprintf('Converting image to grayscale!\n');
f = rgb2gray(f);
stopit_show(f, 'Grayscale image', 233);

fprintf('Validating image size...\n');
img_size= size(f);
IMG_DATA.height = img_size(1,1);
IMG_DATA.width = img_size(1,2);
if IMG_DATA.height ~= IMG_SETTINGS.valid_height || IMG_DATA.width ~= IMG_SETTINGS.valid_width
    msg = sprintf('Invalid image size: %dx%d! Expected image size: %dx%d.', IMG_DATA.height, IMG_DATA.width, IMG_SETTINGS.valid_width, IMG_SETTINGS.valid_height);
    show_raise_error(msg);
end;

b = im2bw(f, 0.9);
stopit_show(b, 'Black & White image', 233);

fprintf('Validating tenis court lines...\n');
validate_lines(b);

fprintf('Finding tennis ball...\n');
find_tennis_ball(f);
if ~IMG_DATA.ball_found
    r = 'OUT';
    gc = g;
    stopit_show(IMG_SETTINGS.(r), 'Result', 231);
    closeit();
    fprintf('Result: %s \n', r);
    return;
end

fprintf('Calculating tennis court regions of interest...\n');
calc_ROIs(matchtype, playerside, shottype, varargin);

gf = IMG_DATA.region_g;
stopit_show(mat2gray(gf), 'Tennis Court Regions', 235)
%Pinto las regiones de interes con negro (=0). igual que las líneas de
%división de la cancha
for i = IMG_DATA.ROIs
    gf(gf == i) = 0;
end;
%El resto de las regiones no involucradas las paso a 0. En esta instancia
%gf contiene una imagen binaria con todas las regiones de interes unidas 
%a las líneas de división de la cancha y las lineas de división de las 
%regiones no tenidas en cuenta.
gf(gf ~= 0) = 1;
stopit_show(mat2gray(gf), 'Tennis Court Regions of Interest', 235);
%El siguiente paso es eliminar las lineas de división de las regiones no
%tenidas en cuenta, de tal manera de que nos quede un unico rectangulo
%compuesto solo por la composición de todas las areas de interes + sus
%lineas de división. 
% Para esto utilizamos close and open - CHAPTER 9 - SEC. 9.3 Opening and
% closing
fprintf('Applying opening and closing...\n');
st = strel('square', IMG_SETTINGS.strel_court_line_size);
gf = logical(gf);
rr = imclose(gf, st);
rr = imopen(rr, st);
%rr contiene solo la región de la cancha relevante
stopit_show(rr, 'Tennis Court Regions of Interest (Cropped)', 235);

ball_center_x_coord = uint16(IMG_DATA.centers(2));
ball_center_y_coord = uint16(IMG_DATA.centers(1));
ball_center_value = f(ball_center_x_coord, ball_center_y_coord);

ff = f;
ff(ff ~= ball_center_value) = 0;
ff = imcomplement(logical(ff));
%ff contiene solo la pelotita
stopit_show(ff, 'Ball position', 235);

fprintf('Calculating ball position against region...\n');
%combinamos las dos imagenes logicas para obtner una imagen que tenga
%el area de interes y la pelotita
ff = immultiply(ff, rr);
stopit_show(ff, 'Tennis Court Regions & Ball Position (region grow - open&close)', 235);
%si el area de interes y la pelotita forman una sola región, es porque la 
%pelotita pico dentro del area en cuestión (IN). En caso contrario el área de
%interes y la pelotita estan en regiones separadas con lo cual el pique de
%la misma fue afuera (OUT).
[gg, NR, SI, TI] = regiongrow(ff, 0, 0);
if NR > 1
    r = 'OUT';
else
    r = 'IN';
end;

%recorto la imagen original para mostrar la zona de pique de la pelotita en
%mas detalle
width = double(150);
height = double(150);
xmin = double(ball_center_x_coord - (width / 2));
ymin = double(ball_center_y_coord - (height / 2));
re = [ymin xmin width height];
gc = imcrop(g, re);

stopit_show(gc, 'Ball Position (Zoom)', 236);
stopit_show(IMG_SETTINGS.(r), 'Result', 231);

closeit();

fprintf('Result: %s\n', r);

end

function [] = closeit()
    global IMG_SETTINGS;
    if IMG_SETTINGS.show_steps && IMG_SETTINGS.close_end
        close;
    end;
end

function [] = stopit_show(g, title_str, plotcoords)
  global IMG_SETTINGS;
  if IMG_SETTINGS.show_steps   
    subplot(plotcoords);
    imshow(g);
    title(title_str);
    stopit;
  end 
end

function [] = show_raise_error(msg) 
    global IMG_SETTINGS;
    stopit_show(IMG_SETTINGS.('ERROR'), msg, 231);
    closeit();
    error(msg);
end

function [] = stopit()
  % Auxiliary function to run the main function in steps  
  global IMG_SETTINGS;
  if IMG_SETTINGS.pause_steps 
    fprintf('Paused. Press any key to resume...\n');
    pause;
  end;
end

function [] = find_tennis_ball(g)
  %busca una pelotita de tenis en la imagen, si detecta mas de una lanza un
  %error
  global IMG_SETTINGS;  
  global IMG_DATA;
  
  stopit_show(g, 'Tennis Ball Detection (Circular Hough Transform (CHT))', 234);
  
  [centers, radii, metric] = imfindcircles(g,IMG_SETTINGS.find_circles_radius_range, ... 
                            'Sensitivity',IMG_SETTINGS.find_circles_sensitivity, ...
                            'ObjectPolarity', IMG_SETTINGS.find_circles_object_polarity);
  
  ball_count = length(radii);
                        
  if IMG_SETTINGS.show_steps
    viscircles(centers, radii,'EdgeColor','r','LineStyle','-','LineWidth',3);
  end;
  
  if ball_count > 1
      msg = 'Invalid image! More than 1 ball detected!';
      show_raise_error(msg);
  elseif ball_count == 1
      fprintf('Tennis ball detected!\n');
      IMG_DATA.ball_found = 1;
      IMG_DATA.centers = centers;
      IMG_DATA.radii = radii;
      IMG_DATA.metric = metric;
  else
      fprintf('No tennis ball detected!\n');
      IMG_DATA.ball_found = 0;
  end;    
end

function [] = validate_lines(bwimg)
  % valida que la imagen tenga una cancha de tenis válida
  % utilizando REGION-GROWING - DIPUM-CHAPTER-10-SEC_10.4.2
  global IMG_SETTINGS;
  global IMG_DATA;
  
  [g, NR, SI, TI] = regiongrow(bwimg, 0, 0);
  
  IMG_DATA.region_g = g;
  IMG_DATA.region_NR = NR;
  IMG_DATA.region_SI = SI;
  IMG_DATA.region_TI = TI;
  
  if IMG_SETTINGS.valid_regions_count ~= NR
    msg = 'The image does not containt a valid tenis court!';
    show_raise_error(msg);
  end;
end

function [] = calc_ROIs(matchtype, playerside, shottype, varargin)
    global IMG_DATA;
    global IMG_SETTINGS;
    if strcmp(shottype, 'SERVICE')
        servicedir = char(varargin{1});
        IMG_DATA.ROIs = IMG_SETTINGS.(matchtype).(playerside).(shottype).(servicedir);
    else
        IMG_DATA.ROIs = IMG_SETTINGS.(matchtype).(playerside).(shottype);
    end;
end


