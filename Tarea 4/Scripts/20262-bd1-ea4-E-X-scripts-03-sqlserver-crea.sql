
-- rol: Define los privilegios y accesos en el sistema (Administrador, Auxiliar, Miembro, visitante)
CREATE TABLE rol (
    id_rol INT IDENTITY(1,1) NOT NULL,
    nombre_rol NVARCHAR(100) NOT NULL,
    descripcion_rol NVARCHAR(MAX) NOT NULL,
    CONSTRAINT pk_rol PRIMARY KEY (id_rol)
);

-- tipo_usuario: Categorizacion para clasificacion y estadistica institucional (Estudiante, Docente, Egresado, etc.)
CREATE TABLE tipo_usuario (
    id_tipo_usuario INT IDENTITY(1,1) NOT NULL,
    nombre_tipo_usuario NVARCHAR(100) NOT NULL,
    descripcion_tipo NVARCHAR(MAX) NOT NULL,
    CONSTRAINT pk_tipo_usuario PRIMARY KEY (id_tipo_usuario)
);

-- perfil: Registra las areas de estudio, biografia e intereses del usuario o grupo
CREATE TABLE perfil (
    id_perfil INT IDENTITY(1,1) NOT NULL,
    area_estudio NVARCHAR(100) NOT NULL,
    biografia_corta NVARCHAR(MAX) NULL,
    fecha_actualizacion DATE NULL,
    CONSTRAINT pk_perfil PRIMARY KEY (id_perfil)
);

-- usuario: Entidad central que administra los datos principales de los miembros de la red social
CREATE TABLE usuario (
    id_usuario INT IDENTITY(1,1) NOT NULL,
    id_rol INT NOT NULL,
    id_tipo_usuario INT NOT NULL,
    id_perfil INT NOT NULL,
    nombres NVARCHAR(50) NOT NULL,
    apellidos NVARCHAR(50) NOT NULL,
    correo_institucional NVARCHAR(150) NOT NULL,
    clave_hash NVARCHAR(255) NOT NULL,
    fecha_registro DATETIME2(0) NOT NULL CONSTRAINT df_usuario_fecha_registro DEFAULT SYSDATETIME(),
    estado_usuario NVARCHAR(20) NOT NULL,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_correo_institucional UNIQUE (correo_institucional),
    CONSTRAINT fk_usuario_id_rol FOREIGN KEY (id_rol) REFERENCES rol(id_rol),
    CONSTRAINT fk_usuario_id_tipo_usuario FOREIGN KEY (id_tipo_usuario) REFERENCES tipo_usuario(id_tipo_usuario),
    CONSTRAINT fk_usuario_id_perfil FOREIGN KEY (id_perfil) REFERENCES perfil(id_perfil),
    CONSTRAINT ck_usuario_estado_usuario CHECK (estado_usuario IN (N'Activo', N'Suspendido', N'En Evaluación'))
);

-- publicacion: Almacena los contenidos, posts y recursos academicos compartidos por los usuarios
CREATE TABLE publicacion (
    id_publicacion INT IDENTITY(1,1) NOT NULL,
    id_usuario_autor INT NOT NULL,
    titulo_publicacion NVARCHAR(100) NOT NULL,
    contenido_publicacion NVARCHAR(MAX) NOT NULL,
    fecha_publicacion DATETIME2(0) NOT NULL CONSTRAINT df_publicacion_fecha_publicacion DEFAULT SYSDATETIME(),
    estado_publicacion NVARCHAR(100) NOT NULL,
    CONSTRAINT pk_publicacion PRIMARY KEY (id_publicacion),
    CONSTRAINT fk_publicacion_id_usuario_autor FOREIGN KEY (id_usuario_autor) REFERENCES usuario(id_usuario),
    CONSTRAINT ck_publicacion_estado_publicacion CHECK (estado_publicacion IN (N'Visible', N'Oculto', N'Eliminado'))
);

-- comentario: Almacena las opiniones y respuestas en las publicaciones
CREATE TABLE comentario (
    id_comentario INT IDENTITY(1,1) NOT NULL,
    id_publicacion INT NOT NULL,
    id_usuario_comentador INT NOT NULL,
    texto_comentario NVARCHAR(MAX) NOT NULL,
    fecha_comentario DATETIME2(0) NOT NULL CONSTRAINT df_comentario_fecha_comentario DEFAULT SYSDATETIME(),
    CONSTRAINT pk_comentario PRIMARY KEY (id_comentario),
    CONSTRAINT fk_comentario_id_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion),
    CONSTRAINT fk_comentario_id_usuario_comentador FOREIGN KEY (id_usuario_comentador) REFERENCES usuario(id_usuario)
);

-- grupo: Comunidades academicas, clubes de interes o equipos de trabajo universitario
CREATE TABLE grupo (
    id_grupo INT IDENTITY(1,1) NOT NULL,
    id_usuario_creador INT NOT NULL,
    id_perfil INT NOT NULL,
    nombre_grupo NVARCHAR(100) NOT NULL,
    descripcion_grupo NVARCHAR(MAX) NULL,
    fecha_creacion DATE NOT NULL CONSTRAINT df_grupo_fecha_creacion DEFAULT CAST(GETDATE() AS DATE),
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT fk_grupo_id_usuario_creador FOREIGN KEY (id_usuario_creador) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_grupo_id_perfil FOREIGN KEY (id_perfil) REFERENCES perfil(id_perfil)
);

-- tipo_servicio: Clasificacion y catalogo de tipos de servicios ofrecidos en la red social
CREATE TABLE tipo_servicio (
    id_tipo_servicio INT IDENTITY(1,1) NOT NULL,
    nombre_tipo_servicio NVARCHAR(100) NOT NULL,
    descripcion_categoria NVARCHAR(MAX) NOT NULL,
    CONSTRAINT pk_tipo_servicio PRIMARY KEY (id_tipo_servicio)
);

-- servicio: Registro de servicios academicos o personales prestados por usuarios
CREATE TABLE servicio (
    id_servicio INT IDENTITY(1,1) NOT NULL,
    id_usuario_ofertante INT NOT NULL,
    id_tipo_servicio INT NOT NULL,
    titulo_servicio NVARCHAR(100) NOT NULL,
    descripcion_servicio NVARCHAR(MAX) NOT NULL,
    precio NUMERIC(10,2) NOT NULL,
    duracion_estimada NVARCHAR(50) NOT NULL,
    ubicacion NVARCHAR(100) NOT NULL,
    estado_servicio NVARCHAR(100) NOT NULL,
    CONSTRAINT pk_servicio PRIMARY KEY (id_servicio),
    CONSTRAINT fk_servicio_id_usuario_ofertante FOREIGN KEY (id_usuario_ofertante) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_servicio_id_tipo_servicio FOREIGN KEY (id_tipo_servicio) REFERENCES tipo_servicio(id_tipo_servicio),
    CONSTRAINT ck_servicio_precio CHECK (precio >= 0),
    CONSTRAINT ck_servicio_ubicacion CHECK (ubicacion IN (N'Presencial', N'Remoto')),
    CONSTRAINT ck_servicio_estado_servicio CHECK (estado_servicio IN (N'Activo', N'Pausado', N'Inactivo'))
);

-- tipo_producto: Catalogo de categorias para la compra y venta de productos
CREATE TABLE tipo_producto (
    id_tipo_producto INT IDENTITY(1,1) NOT NULL,
    nombre_tipo_producto NVARCHAR(100) NOT NULL,
    descripcion_categoria NVARCHAR(MAX) NOT NULL,
    CONSTRAINT pk_tipo_producto PRIMARY KEY (id_tipo_producto)
);

-- producto: Articulos e insumos ofertados por la comunidad estudiantil y docente
CREATE TABLE producto (
    id_producto INT IDENTITY(1,1) NOT NULL,
    id_usuario_vendedor INT NOT NULL,
    id_tipo_producto INT NOT NULL,
    nombre_producto NVARCHAR(100) NOT NULL,
    descripcion_producto NVARCHAR(MAX) NOT NULL,
    precio_producto NUMERIC(10,2) NOT NULL,
    estado_producto NVARCHAR(100) NOT NULL,
    fecha_publicacion DATE NOT NULL CONSTRAINT df_producto_fecha_publicacion DEFAULT CAST(GETDATE() AS DATE),
    CONSTRAINT pk_producto PRIMARY KEY (id_producto),
    CONSTRAINT fk_producto_id_usuario_vendedor FOREIGN KEY (id_usuario_vendedor) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_producto_id_tipo_producto FOREIGN KEY (id_tipo_producto) REFERENCES tipo_producto(id_tipo_producto),
    CONSTRAINT ck_producto_precio_producto CHECK (precio_producto >= 0),
    CONSTRAINT ck_producto_estado_producto CHECK (estado_producto IN (N'Disponible', N'Vendido', N'Reservado'))
);

-- tipo_evento: Clasificacion de eventos academicos, culturales o sociales
CREATE TABLE tipo_evento (
    id_tipo_evento INT IDENTITY(1,1) NOT NULL,
    nombre_tipo_evento NVARCHAR(100) NOT NULL,
    descripcion_tipo NVARCHAR(MAX) NOT NULL,
    CONSTRAINT pk_tipo_evento PRIMARY KEY (id_tipo_evento)
);

-- evento: Eventos creados por usuarios organizadores para ser difundidos en la red
CREATE TABLE evento (
    id_evento INT IDENTITY(1,1) NOT NULL,
    id_usuario_organizador INT NOT NULL,
    id_tipo_evento INT NOT NULL,
    titulo_evento NVARCHAR(100) NOT NULL,
    descripcion_evento NVARCHAR(MAX) NOT NULL,
    fecha_hora_inicio DATETIME2(0) NOT NULL,
    fecha_hora_fin DATETIME2(0) NOT NULL,
    lugar_evento NVARCHAR(100) NOT NULL,
    cupo_maximo INT NULL,
    CONSTRAINT pk_evento PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_id_usuario_organizador FOREIGN KEY (id_usuario_organizador) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_evento_id_tipo_evento FOREIGN KEY (id_tipo_evento) REFERENCES tipo_evento(id_tipo_evento),
    CONSTRAINT ck_evento_fecha_hora_fin CHECK (fecha_hora_fin > fecha_hora_inicio),
    CONSTRAINT ck_evento_cupo_maximo CHECK (cupo_maximo IS NULL OR cupo_maximo > 0)
);

-- notificacion: Alertas y avisos generados automaticamente para notificar interacciones al usuario
CREATE TABLE notificacion (
    id_notificacion INT IDENTITY(1,1) NOT NULL,
    id_usuario INT NOT NULL,
    titulo_notificacion NVARCHAR(100) NOT NULL,
    mensaje_notificacion NVARCHAR(MAX) NOT NULL,
    tipo_notificacion NVARCHAR(100) NOT NULL,
    estado_lectura NVARCHAR(100) NOT NULL,
    fecha_envio DATETIME2(0) NOT NULL CONSTRAINT df_notificacion_fecha_envio DEFAULT SYSDATETIME(),
    CONSTRAINT pk_notificacion PRIMARY KEY (id_notificacion),
    CONSTRAINT fk_notificacion_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    CONSTRAINT ck_notificacion_tipo_notificacion CHECK (tipo_notificacion IN (N'comentario', N'evento', N'mensaje')),
    CONSTRAINT ck_notificacion_estado_lectura CHECK (estado_lectura IN (N'leído', N'no leído'))
);

-- mensaje: Mensajeria privada y conversacion en tiempo real entre usuarios
CREATE TABLE mensaje (
    id_mensaje INT IDENTITY(1,1) NOT NULL,
    id_emisor INT NOT NULL,
    id_receptor INT NOT NULL,
    contenido_mensaje NVARCHAR(MAX) NOT NULL,
    fecha_hora_envio DATETIME2(0) NOT NULL,
    estado_mensaje NVARCHAR(100) NOT NULL,
    CONSTRAINT pk_mensaje PRIMARY KEY (id_mensaje),
    CONSTRAINT fk_mensaje_id_emisor FOREIGN KEY (id_emisor) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_mensaje_id_receptor FOREIGN KEY (id_receptor) REFERENCES usuario(id_usuario),
    CONSTRAINT ck_mensaje_estado_mensaje CHECK (estado_mensaje IN (N'enviado', N'entregado', N'leído'))
);

-- valoracion: Resenas y calificaciones de satisfaccion (1 a 5 estrellas) para servicios o productos
CREATE TABLE valoracion (
    id_valoracion INT IDENTITY(1,1) NOT NULL,
    id_usuario_evaluador INT NOT NULL,
    id_servicio INT NULL,
    id_producto INT NULL,
    puntuacion NUMERIC(2,1) NOT NULL,
    comentario_resena NVARCHAR(MAX) NULL,
    fecha_valoracion DATE NOT NULL,
    CONSTRAINT pk_valoracion PRIMARY KEY (id_valoracion),
    CONSTRAINT fk_valoracion_id_usuario_evaluador FOREIGN KEY (id_usuario_evaluador) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_valoracion_id_servicio FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio),
    CONSTRAINT fk_valoracion_id_producto FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT ck_valoracion_puntuacion CHECK (puntuacion BETWEEN 1 AND 5),
    CONSTRAINT ck_valoracion_servicio_o_producto CHECK (id_servicio IS NOT NULL OR id_producto IS NOT NULL)
);

-- reaccion: Expresiones inmediatas de los usuarios ante el contenido publicado en la red
CREATE TABLE reaccion (
    id_reaccion INT IDENTITY(1,1) NOT NULL,
    id_usuario INT NOT NULL,
    id_publicacion INT NOT NULL,
    tipo_reaccion NVARCHAR(100) NOT NULL,
    fecha_reaccion DATETIME2(0) NOT NULL CONSTRAINT df_reaccion_fecha_reaccion DEFAULT SYSDATETIME(),
    CONSTRAINT pk_reaccion PRIMARY KEY (id_reaccion),
    CONSTRAINT fk_reaccion_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_reaccion_id_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion),
    CONSTRAINT ck_reaccion_tipo_reaccion CHECK (tipo_reaccion IN (N'me gusta', N'útil', N'interesante'))
);

-- conexion: Gestion de vinculos y solicitudes para crear redes de contactos dentro de la comunidad
CREATE TABLE conexion (
    id_conexion INT IDENTITY(1,1) NOT NULL,
    id_usuario_solicitante INT NOT NULL,
    id_usuario_receptor INT NOT NULL,
    estado_conexion NVARCHAR(100) NOT NULL,
    fecha_solicitud DATE NOT NULL,
    fecha_respuesta DATE NULL,
    CONSTRAINT pk_conexion PRIMARY KEY (id_conexion),
    CONSTRAINT fk_conexion_id_usuario_solicitante FOREIGN KEY (id_usuario_solicitante) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_conexion_id_usuario_receptor FOREIGN KEY (id_usuario_receptor) REFERENCES usuario(id_usuario),
    CONSTRAINT ck_conexion_estado_conexion CHECK (estado_conexion IN (N'pendiente', N'aceptada', N'rechazada'))
);

-- miembro_grupo: Tabla de union: usuarios que pertenecen a grupos (fundador y miembros)
CREATE TABLE miembro_grupo (
    id_usuario INT NOT NULL,
    id_grupo INT NOT NULL,
    rol_en_grupo NVARCHAR(100) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    CONSTRAINT pk_miembro_grupo PRIMARY KEY (id_usuario, id_grupo),
    CONSTRAINT fk_miembro_grupo_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_miembro_grupo_id_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo),
    CONSTRAINT ck_miembro_grupo_rol_en_grupo CHECK (rol_en_grupo IN (N'Fundador', N'Miembro'))
);

-- solicitud_servicio: Tabla de union: solicitudes que los usuarios hacen sobre servicios de otros usuarios
CREATE TABLE solicitud_servicio (
    id_usuario_solicitante INT NOT NULL,
    id_servicio INT NOT NULL,
    fecha_solicitud DATE NOT NULL,
    estado_solicitud NVARCHAR(100) NOT NULL,
    CONSTRAINT pk_solicitud_servicio PRIMARY KEY (id_usuario_solicitante, id_servicio),
    CONSTRAINT fk_solicitud_servicio_id_usuario_solicitante FOREIGN KEY (id_usuario_solicitante) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_solicitud_servicio_id_servicio FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio),
    CONSTRAINT ck_solicitud_servicio_estado_solicitud CHECK (estado_solicitud IN (N'Pendiente', N'Aceptada', N'Rechazada', N'Finalizada'))
);

-- compra_producto: Tabla de union: compras que los usuarios realizan sobre productos de otros usuarios
CREATE TABLE compra_producto (
    id_usuario_comprador INT NOT NULL,
    id_producto INT NOT NULL,
    fecha_compra DATE NOT NULL,
    cantidad INT NOT NULL,
    CONSTRAINT pk_compra_producto PRIMARY KEY (id_usuario_comprador, id_producto),
    CONSTRAINT fk_compra_producto_id_usuario_comprador FOREIGN KEY (id_usuario_comprador) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_compra_producto_id_producto FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT ck_compra_producto_cantidad CHECK (cantidad > 0)
);

-- asistencia_evento: Tabla de union: usuarios que confirman asistencia a un evento
CREATE TABLE asistencia_evento (
    id_usuario INT NOT NULL,
    id_evento INT NOT NULL,
    fecha_registro DATE NOT NULL,
    estado_asistencia NVARCHAR(100) NOT NULL,
    CONSTRAINT pk_asistencia_evento PRIMARY KEY (id_usuario, id_evento),
    CONSTRAINT fk_asistencia_evento_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_asistencia_evento_id_evento FOREIGN KEY (id_evento) REFERENCES evento(id_evento),
    CONSTRAINT ck_asistencia_evento_estado_asistencia CHECK (estado_asistencia IN (N'Confirmado', N'Cancelado', N'Asistió'))
);

-- perfil_habilidad: Tabla derivada (1FN) del atributo multivaluado habilidades_intereses_json de perfil
CREATE TABLE perfil_habilidad (
    id_perfil INT NOT NULL,
    habilidad NVARCHAR(100) NOT NULL,
    CONSTRAINT pk_perfil_habilidad PRIMARY KEY (id_perfil, habilidad),
    CONSTRAINT fk_perfil_habilidad_id_perfil FOREIGN KEY (id_perfil) REFERENCES perfil(id_perfil)
);

