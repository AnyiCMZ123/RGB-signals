%interfaz grafica
interfaz = uifigure('Name', 'Project', 'Position', [100, 70, 800, 600]);

fondo_axes = axes('Parent', interfaz, 'Units', 'normalized', 'Position', [0, 0, 1, 1]);
imagen_fondo = imread('castle.jpg'); 
image(imagen_fondo, 'Parent', fondo_axes);
axis(fondo_axes, 'off');

boton_iniciar = uibutton(interfaz, 'Text', 'Iniciar', 'Position', [370, 200, 100, 80]);
boton_iniciar.ButtonPushedFcn = @(src, event) iniciarCaptura(src);

function iniciarCaptura(~)
    
    close(gcf);

    cam = webcam;

    preview(cam);

    
    pause(3);

   
    imagen = snapshot(cam);

    
    clear cam;

   
    figura_principal = figure('Name', 'Catillos RGB');
    
% Convertir la imagen a escala de grises
imagen_gris = rgb2gray(imagen);

% Calcular la transformada de Fourier 1D para cada columna
transformada_fourier = fft(imagen_gris);

% Calcular el espectro de amplitud
espectro_amplitud = log(1 + abs(fftshift(transformada_fourier)));

% Crear un filtro para resaltar o atenuar los colores específicos
filtro_color = zeros(size(imagen_gris));
rango_colores = [1, 100]; 
filtro_color(rango_colores(1):rango_colores(2), :) = 1;
filtro_color(end-rango_colores(2)+1:end-rango_colores(1)+1, :) = 1;

% Aplicar el filtro a la transformada de Fourier en paralelo
transformada_fourier_filtrada = zeros(size(transformada_fourier));
parfor i = 1:size(imagen_gris, 2)
    transformada_fourier_filtrada(:, i) = transformada_fourier(:, i) .* filtro_color(:, i);
end

% Calcular la inversa de la transformada de Fourier 
imagen_filtrada = ifft(transformada_fourier_filtrada);

% Crear un grupo de pestañas
tabgroup = uitabgroup(figura_principal);

% Pestaña para la imagen original
pestana_original = uitab(tabgroup, 'Title', 'Imagen Original');
eje_original = axes('Parent', pestana_original);
imshow(imagen, 'Parent', eje_original);
title(eje_original, 'Imagen Original');

% Pestaña para el espectro de amplitud
pestana_espectro = uitab(tabgroup, 'Title', 'Espectro de Amplitud');
eje_espectro = axes('Parent', pestana_espectro);
imagesc(espectro_amplitud, 'Parent', eje_espectro); % Usar imagesc en lugar de imshow
title(eje_espectro, 'Espectro de Amplitud');

% Pestaña para el ajuste de color
pestana_color = uitab(tabgroup, 'Title', 'Ajuste de Color');
eje_color = axes('Parent', pestana_color);

% Crear controles deslizantes para rojo, azul y verde
barra_rojo = uicontrol('Style', 'slider', 'Parent', pestana_color, 'Position', [50, 50, 120, 20], 'Min', 0, 'Max', 1, 'Value', 0);
barra_azul = uicontrol('Style', 'slider', 'Parent', pestana_color, 'Position', [50, 30, 120, 20], 'Min', 0, 'Max', 1, 'Value', 0);
barra_verde = uicontrol('Style', 'slider', 'Parent', pestana_color, 'Position', [50, 10, 120, 20], 'Min', 0, 'Max', 1, 'Value', 0);

% Etiquetas para las barras deslizantes
uicontrol('Parent', pestana_color, 'Style', 'text', 'Position', [20, 50, 20, 20], 'String', 'R');
uicontrol('Parent', pestana_color, 'Style', 'text', 'Position', [20, 30, 20, 20], 'String', 'B');
uicontrol('Parent', pestana_color, 'Style', 'text', 'Position', [20, 10, 20, 20], 'String', 'G');

% Callbacks para actualizar el filtro de color al cambiar las barras
barra_rojo.Callback = @(src, event) actualizar_filtro_color(barra_rojo, barra_azul, barra_verde, imagen, filtro_color, eje_color);
barra_azul.Callback = @(src, event) actualizar_filtro_color(barra_rojo, barra_azul, barra_verde, imagen, filtro_color, eje_color);
barra_verde.Callback = @(src, event) actualizar_filtro_color(barra_rojo, barra_azul, barra_verde, imagen, filtro_color, eje_color);

% Inicializar la imagen con filtro de color
actualizar_filtro_color(barra_rojo, barra_azul, barra_verde, imagen, filtro_color, eje_color);
function actualizar_filtro_color(barra_rojo, barra_azul, barra_verde, imagen, ~, eje_color)
    brillo_rojo = get(barra_rojo, 'Value');
    brillo_azul = get(barra_azul, 'Value');
    brillo_verde = get(barra_verde, 'Value');
    
    filtro_color = ones(size(imagen), 'uint8');

    % Aplicar filtro rojo
    filtro_color(:, :, 1) = filtro_color(:, :, 1) * brillo_rojo;

    % Aplicar filtro azul
    filtro_color(:, :, 3) = filtro_color(:, :, 3) * brillo_azul;

    % Aplicar filtro verde
    filtro_color(:, :, 2) = filtro_color(:, :, 2) * brillo_verde;

    imagen_color_ajustado = imagen .* filtro_color;
    imshow(imagen_color_ajustado, 'Parent', eje_color);
    title(eje_color, 'Aplicación de filtro RGB');
end

end