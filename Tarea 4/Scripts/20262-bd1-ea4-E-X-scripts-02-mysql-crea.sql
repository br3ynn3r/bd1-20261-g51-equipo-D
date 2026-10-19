
-- rol: Define los privilegios y accesos en el sistema (Administrador, Auxiliar, Miembro, visitante)
CREATE TABLE rol (
    id_rol INT AUTO_INCREMENT NOT NULL,
    nombre_rol VARCHAR(100) NOT NULL,
    descripcion_rol TEXT NOT NULL,
    CONSTRAINT pk_rol PRIMARY KEY (id_rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- tipo_usuario: Categorizacion para clasificacion y estadistica institucional (Estudiante, Docente, Egresado, etc.)
CREATE TABLE tipo_usuario (
    id_tipo_usuario INT AUTO_INCREMENT NOT NULL,
    nombre_tipo_usuario VARCHAR(100) NOT NULL,
    descripcion_tipo TEXT NOT NULL,
    CONSTRAINT pk_tipo_usuario PRIMARY KEY (id_tipo_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- perfil: Registra las areas de estudio, biografia e intereses del usuario o grupo
CREATE TABLE perfil (
    id_perfil INT AUTO_INCREMENT NOT NULL,
    area_estudio VARCHAR(100) NOT NULL,
    biografia_corta TEXT NULL,
    fecha_actualizacion DATE NULL,
    CONSTRAINT pk_perfil PRIMARY KEY (id_perfil)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- usuario: Entidad central que administra los datos principales de los miembros de la red social
CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT NOT NULL,
    id_rol INT NOT NULL,
    id_tipo_usuario INT NOT NULL,
    id_perfil INT NOT NULL,
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    correo_institucional VARCHAR(150) NOT NULL,
    clave_hash VARCHAR(255) NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_usuario VARCHAR(20) NOT NULL,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_correo_institucional UNIQUE (correo_institucional),
    CONSTRAINT fk_usuario_id_rol FOREIGN KEY (id_rol) REFERENCES rol(id_rol) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_usuario_id_tipo_usuario FOREIGN KEY (id_tipo_usuario) REFERENCES tipo_usuario(id_tipo_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_usuario_id_perfil FOREIGN KEY (id_perfil) REFERENCES perfil(id_perfil) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_usuario_estado_usuario CHECK (estado_usuario IN ('Activo', 'Suspendido', 'En Evaluación'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- publicacion: Almacena los contenidos, posts y recursos academicos compartidos por los usuarios
CREATE TABLE publicacion (
    id_publicacion INT AUTO_INCREMENT NOT NULL,
    id_usuario_autor INT NOT NULL,
    titulo_publicacion VARCHAR(100) NOT NULL,
    contenido_publicacion TEXT NOT NULL,
    fecha_publicacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_publicacion VARCHAR(100) NOT NULL,
    CONSTRAINT pk_publicacion PRIMARY KEY (id_publicacion),
    CONSTRAINT fk_publicacion_id_usuario_autor FOREIGN KEY (id_usuario_autor) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_publicacion_estado_publicacion CHECK (estado_publicacion IN ('Visible', 'Oculto', 'Eliminado'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- comentario: Almacena las opiniones y respuestas en las publicaciones
CREATE TABLE comentario (
    id_comentario INT AUTO_INCREMENT NOT NULL,
    id_publicacion INT NOT NULL,
    id_usuario_comentador INT NOT NULL,
    texto_comentario TEXT NOT NULL,
    fecha_comentario DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_comentario PRIMARY KEY (id_comentario),
    CONSTRAINT fk_comentario_id_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_comentario_id_usuario_comentador FOREIGN KEY (id_usuario_comentador) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- grupo: Comunidades academicas, clubes de interes o equipos de trabajo universitario
CREATE TABLE grupo (
    id_grupo INT AUTO_INCREMENT NOT NULL,
    id_usuario_creador INT NOT NULL,
    id_perfil INT NOT NULL,
    nombre_grupo VARCHAR(100) NOT NULL,
    descripcion_grupo TEXT NULL,
    fecha_creacion DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT fk_grupo_id_usuario_creador FOREIGN KEY (id_usuario_creador) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_grupo_id_perfil FOREIGN KEY (id_perfil) REFERENCES perfil(id_perfil) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- tipo_servicio: Clasificacion y catalogo de tipos de servicios ofrecidos en la red social
CREATE TABLE tipo_servicio (
    id_tipo_servicio INT AUTO_INCREMENT NOT NULL,
    nombre_tipo_servicio VARCHAR(100) NOT NULL,
    descripcion_categoria TEXT NOT NULL,
    CONSTRAINT pk_tipo_servicio PRIMARY KEY (id_tipo_servicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- servicio: Registro de servicios academicos o personales prestados por usuarios
CREATE TABLE servicio (
    id_servicio INT AUTO_INCREMENT NOT NULL,
    id_usuario_ofertante INT NOT NULL,
    id_tipo_servicio INT NOT NULL,
    titulo_servicio VARCHAR(100) NOT NULL,
    descripcion_servicio TEXT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    duracion_estimada VARCHAR(50) NOT NULL,
    ubicacion VARCHAR(100) NOT NULL,
    estado_servicio VARCHAR(100) NOT NULL,
    CONSTRAINT pk_servicio PRIMARY KEY (id_servicio),
    CONSTRAINT fk_servicio_id_usuario_ofertante FOREIGN KEY (id_usuario_ofertante) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_servicio_id_tipo_servicio FOREIGN KEY (id_tipo_servicio) REFERENCES tipo_servicio(id_tipo_servicio) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_servicio_precio CHECK (precio >= 0),
    CONSTRAINT ck_servicio_ubicacion CHECK (ubicacion IN ('Presencial', 'Remoto')),
    CONSTRAINT ck_servicio_estado_servicio CHECK (estado_servicio IN ('Activo', 'Pausado', 'Inactivo'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- tipo_producto: Catalogo de categorias para la compra y venta de productos
CREATE TABLE tipo_producto (
    id_tipo_producto INT AUTO_INCREMENT NOT NULL,
    nombre_tipo_producto VARCHAR(100) NOT NULL,
    descripcion_categoria TEXT NOT NULL,
    CONSTRAINT pk_tipo_producto PRIMARY KEY (id_tipo_producto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- producto: Articulos e insumos ofertados por la comunidad estudiantil y docente
CREATE TABLE producto (
    id_producto INT AUTO_INCREMENT NOT NULL,
    id_usuario_vendedor INT NOT NULL,
    id_tipo_producto INT NOT NULL,
    nombre_producto VARCHAR(100) NOT NULL,
    descripcion_producto TEXT NOT NULL,
    precio_producto DECIMAL(10,2) NOT NULL,
    estado_producto VARCHAR(100) NOT NULL,
    fecha_publicacion DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT pk_producto PRIMARY KEY (id_producto),
    CONSTRAINT fk_producto_id_usuario_vendedor FOREIGN KEY (id_usuario_vendedor) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_producto_id_tipo_producto FOREIGN KEY (id_tipo_producto) REFERENCES tipo_producto(id_tipo_producto) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_producto_precio_producto CHECK (precio_producto >= 0),
    CONSTRAINT ck_producto_estado_producto CHECK (estado_producto IN ('Disponible', 'Vendido', 'Reservado'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- tipo_evento: Clasificacion de eventos academicos, culturales o sociales
CREATE TABLE tipo_evento (
    id_tipo_evento INT AUTO_INCREMENT NOT NULL,
    nombre_tipo_evento VARCHAR(100) NOT NULL,
    descripcion_tipo TEXT NOT NULL,
    CONSTRAINT pk_tipo_evento PRIMARY KEY (id_tipo_evento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- evento: Eventos creados por usuarios organizadores para ser difundidos en la red
CREATE TABLE evento (
    id_evento INT AUTO_INCREMENT NOT NULL,
    id_usuario_organizador INT NOT NULL,
    id_tipo_evento INT NOT NULL,
    titulo_evento VARCHAR(100) NOT NULL,
    descripcion_evento TEXT NOT NULL,
    fecha_hora_inicio DATETIME NOT NULL,
    fecha_hora_fin DATETIME NOT NULL,
    lugar_evento VARCHAR(100) NOT NULL,
    cupo_maximo INT NULL,
    CONSTRAINT pk_evento PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_id_usuario_organizador FOREIGN KEY (id_usuario_organizador) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_evento_id_tipo_evento FOREIGN KEY (id_tipo_evento) REFERENCES tipo_evento(id_tipo_evento) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_evento_fecha_hora_fin CHECK (fecha_hora_fin > fecha_hora_inicio),
    CONSTRAINT ck_evento_cupo_maximo CHECK (cupo_maximo IS NULL OR cupo_maximo > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- notificacion: Alertas y avisos generados automaticamente para notificar interacciones al usuario
CREATE TABLE notificacion (
    id_notificacion INT AUTO_INCREMENT NOT NULL,
    id_usuario INT NOT NULL,
    titulo_notificacion VARCHAR(100) NOT NULL,
    mensaje_notificacion TEXT NOT NULL,
    tipo_notificacion VARCHAR(100) NOT NULL,
    estado_lectura VARCHAR(100) NOT NULL,
    fecha_envio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_notificacion PRIMARY KEY (id_notificacion),
    CONSTRAINT fk_notificacion_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_notificacion_tipo_notificacion CHECK (tipo_notificacion IN ('comentario', 'evento', 'mensaje')),
    CONSTRAINT ck_notificacion_estado_lectura CHECK (estado_lectura IN ('leído', 'no leído'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- mensaje: Mensajeria privada y conversacion en tiempo real entre usuarios
CREATE TABLE mensaje (
    id_mensaje INT AUTO_INCREMENT NOT NULL,
    id_emisor INT NOT NULL,
    id_receptor INT NOT NULL,
    contenido_mensaje TEXT NOT NULL,
    fecha_hora_envio DATETIME NOT NULL,
    estado_mensaje VARCHAR(100) NOT NULL,
    CONSTRAINT pk_mensaje PRIMARY KEY (id_mensaje),
    CONSTRAINT fk_mensaje_id_emisor FOREIGN KEY (id_emisor) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_mensaje_id_receptor FOREIGN KEY (id_receptor) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_mensaje_estado_mensaje CHECK (estado_mensaje IN ('enviado', 'entregado', 'leído'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- valoracion: Resenas y calificaciones de satisfaccion (1 a 5 estrellas) para servicios o productos
CREATE TABLE valoracion (
    id_valoracion INT AUTO_INCREMENT NOT NULL,
    id_usuario_evaluador INT NOT NULL,
    id_servicio INT NULL,
    id_producto INT NULL,
    puntuacion DECIMAL(2,1) NOT NULL,
    comentario_resena TEXT NULL,
    fecha_valoracion DATE NOT NULL,
    CONSTRAINT pk_valoracion PRIMARY KEY (id_valoracion),
    CONSTRAINT fk_valoracion_id_usuario_evaluador FOREIGN KEY (id_usuario_evaluador) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_valoracion_id_servicio FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_valoracion_id_producto FOREIGN KEY (id_producto) REFERENCES producto(id_producto) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT ck_valoracion_puntuacion CHECK (puntuacion BETWEEN 1 AND 5),
    CONSTRAINT ck_valoracion_servicio_o_producto CHECK (id_servicio IS NOT NULL OR id_producto IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- reaccion: Expresiones inmediatas de los usuarios ante el contenido publicado en la red
CREATE TABLE reaccion (
    id_reaccion INT AUTO_INCREMENT NOT NULL,
    id_usuario INT NOT NULL,
    id_publicacion INT NOT NULL,
    tipo_reaccion VARCHAR(100) NOT NULL,
    fecha_reaccion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_reaccion PRIMARY KEY (id_reaccion),
    CONSTRAINT fk_reaccion_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_reaccion_id_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_reaccion_tipo_reaccion CHECK (tipo_reaccion IN ('me gusta', 'útil', 'interesante'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- conexion: Gestion de vinculos y solicitudes para crear redes de contactos dentro de la comunidad
CREATE TABLE conexion (
    id_conexion INT AUTO_INCREMENT NOT NULL,
    id_usuario_solicitante INT NOT NULL,
    id_usuario_receptor INT NOT NULL,
    estado_conexion VARCHAR(100) NOT NULL,
    fecha_solicitud DATE NOT NULL,
    fecha_respuesta DATE NULL,
    CONSTRAINT pk_conexion PRIMARY KEY (id_conexion),
    CONSTRAINT fk_conexion_id_usuario_solicitante FOREIGN KEY (id_usuario_solicitante) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_conexion_id_usuario_receptor FOREIGN KEY (id_usuario_receptor) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_conexion_estado_conexion CHECK (estado_conexion IN ('pendiente', 'aceptada', 'rechazada'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- miembro_grupo: Tabla de union: usuarios que pertenecen a grupos (fundador y miembros)
CREATE TABLE miembro_grupo (
    id_usuario INT NOT NULL,
    id_grupo INT NOT NULL,
    rol_en_grupo VARCHAR(100) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    CONSTRAINT pk_miembro_grupo PRIMARY KEY (id_usuario, id_grupo),
    CONSTRAINT fk_miembro_grupo_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_miembro_grupo_id_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_miembro_grupo_rol_en_grupo CHECK (rol_en_grupo IN ('Fundador', 'Miembro'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- solicitud_servicio: Tabla de union: solicitudes que los usuarios hacen sobre servicios de otros usuarios
CREATE TABLE solicitud_servicio (
    id_usuario_solicitante INT NOT NULL,
    id_servicio INT NOT NULL,
    fecha_solicitud DATE NOT NULL,
    estado_solicitud VARCHAR(100) NOT NULL,
    CONSTRAINT pk_solicitud_servicio PRIMARY KEY (id_usuario_solicitante, id_servicio),
    CONSTRAINT fk_solicitud_servicio_id_usuario_solicitante FOREIGN KEY (id_usuario_solicitante) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_solicitud_servicio_id_servicio FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_solicitud_servicio_estado_solicitud CHECK (estado_solicitud IN ('Pendiente', 'Aceptada', 'Rechazada', 'Finalizada'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- compra_producto: Tabla de union: compras que los usuarios realizan sobre productos de otros usuarios
CREATE TABLE compra_producto (
    id_usuario_comprador INT NOT NULL,
    id_producto INT NOT NULL,
    fecha_compra DATE NOT NULL,
    cantidad INT NOT NULL,
    CONSTRAINT pk_compra_producto PRIMARY KEY (id_usuario_comprador, id_producto),
    CONSTRAINT fk_compra_producto_id_usuario_comprador FOREIGN KEY (id_usuario_comprador) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_compra_producto_id_producto FOREIGN KEY (id_producto) REFERENCES producto(id_producto) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_compra_producto_cantidad CHECK (cantidad > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- asistencia_evento: Tabla de union: usuarios que confirman asistencia a un evento
CREATE TABLE asistencia_evento (
    id_usuario INT NOT NULL,
    id_evento INT NOT NULL,
    fecha_registro DATE NOT NULL,
    estado_asistencia VARCHAR(100) NOT NULL,
    CONSTRAINT pk_asistencia_evento PRIMARY KEY (id_usuario, id_evento),
    CONSTRAINT fk_asistencia_evento_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_asistencia_evento_id_evento FOREIGN KEY (id_evento) REFERENCES evento(id_evento) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_asistencia_evento_estado_asistencia CHECK (estado_asistencia IN ('Confirmado', 'Cancelado', 'Asistió'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- perfil_habilidad: Tabla derivada (1FN) del atributo multivaluado habilidades_intereses_json de perfil
CREATE TABLE perfil_habilidad (
    id_perfil INT NOT NULL,
    habilidad VARCHAR(100) NOT NULL,
    CONSTRAINT pk_perfil_habilidad PRIMARY KEY (id_perfil, habilidad),
    CONSTRAINT fk_perfil_habilidad_id_perfil FOREIGN KEY (id_perfil) REFERENCES perfil(id_perfil) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
