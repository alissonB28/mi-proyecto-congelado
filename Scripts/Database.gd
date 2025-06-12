extends Node

var db = null

func _ready():
	db = SQLite.new()
	db.path = "user://Evanesce.db"
	db.open_db()
	crear_tablas()

func crear_tablas():
	db.query("""
		CREATE TABLE IF NOT EXISTS usuario (
			id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
			nombre TEXT,
			correo TEXT UNIQUE,
			contrasena TEXT
		);
		
		CREATE TABLE IF NOT EXISTS simulaciones (
			id_simulacion INTEGER,
			id_usuario INTEGER NOT NULL,
			titulo TEXT,
			tiempo TEXT,
			parametros TEXT,
			resultados TEXT,
			descripcion TEXT,
			PRIMARY KEY(id_simulacion AUTOINCREMENT),
			FOREIGN KEY(id_usuario) REFERENCES usuario (id_usuario)
		);
	""")
	
#Hash contraseñas
func hash_contrasena(contrasena: String) -> String:
	var hasher = HashingContext.new()
	hasher.start(HashingContext.HASH_SHA256)
	hasher.update(contrasena.to_utf8_buffer())
	return hasher.finish().hex_encode()


# Registro
func registro_usuario(nombre: String, correo: String, contrasena: String) -> bool:
	# Comprobar si el correo ya existe
	var check_query = "SELECT * FROM usuario WHERE correo = ?"
	var exists = db.query_with_bindings(check_query, [correo])
	
	if exists and db.query_result.size() > 0:
		print("Correo ya registrado")
		return false
	
	# Insertar nuevo usuario
	var hashC = hash_contrasena(contrasena)
	var insert_query = "INSERT INTO usuario (nombre, correo, contrasena) VALUES (?, ?, ?)"
	var insert_params = [nombre, correo, hashC]
	var insert_success = db.query_with_bindings(insert_query, insert_params)

	if insert_success:
		print("Usuario registrado correctamente")
	else:
		print("Error al registrar")

	return insert_success


# Login
func login(correo: String, contrasena: String) -> Dictionary:
	var hashC = hash_contrasena(contrasena)
	var query = "SELECT * FROM usuario WHERE correo = ? AND contrasena = ?"
	var params = [correo, hashC]

	var success = db.query_with_bindings(query, params)
	if success and db.query_result.size() == 1:
		print("Login exitoso")
		return db.query_result[0]
	
	print("Login fallido")
	return {}


#Guardar simulaciones		
func guardar_simulacion_db(sim: SimulacionGuardada) -> void:
	var datos = sim.to_dict()
	var insert_query = """
		INSERT INTO simulaciones (id_usuario, titulo, tiempo, parametros, resultados, descripcion)
		VALUES (?, ?, ?, ?, ?, ?)
	"""
	var insert_params = [
		datos["id_usuario"],
		datos["titulo"],
		datos["tiempo"],
		datos["parametros"],
		datos["resultados"],
		datos["descripcion"]
	]
	var success = db.query_with_bindings(insert_query, insert_params)
	if success:
		print("Simulación guardada correctamente.")
	else:
		print("Error al guardar la simulación.")

#Historial simulaciones
func cargar_historial_db(id_usuario: int) -> Array:
	var query = """
		SELECT id_simulacion, titulo, tiempo, descripcion
		FROM simulaciones
		WHERE id_usuario = ?
		ORDER BY id_simulacion DESC
	"""
	if db.query_with_bindings(query, [id_usuario]):
		return db.query_result
	return []

#para abrir la simulacion desde el historial
func obtener_simulacion_id(id_simulacion: int) -> SimulacionGuardada:
	var query = "SELECT * FROM simulaciones WHERE id_simulacion = ?"
	var success = db.query_with_bindings(query, [id_simulacion])
	if success and db.query_result.size() > 0:
		var fila =  db.query_result[0]
		var sim = SimulacionGuardada.new()
		sim.id_simulacion = fila["id_simulacion"]
		sim.id_usuario = fila["id_usuario"]
		sim.titulo = fila["titulo"]
		sim.tiempo = fila["tiempo"]
		sim.descripcion = fila["descripcion"]
		
		# Convertir JSON a Dictionary
		sim.parametros = JSON.parse_string(fila["parametros"])
		sim.resultados = JSON.parse_string(fila["resultados"])
		return sim	
	return null 
	
func eliminar_simulacion_id(id_simulacion: int, id_usuario: int):
	var query = "DELETE FROM simulaciones WHERE id_simulacion = ? AND id_usuario = ?"
	var success = db.query_with_bindings(query, [id_simulacion,Global.id_usuario])
	if success:
		print("eliminado databaseeee")
	else:
		print("error database")

	
func eliminar_simulaciones(id_usuario: int) -> int:
	var query = "DELETE FROM simulaciones WHERE id_usuario = %d"% id_usuario
	var cont: int = db.query_result.size()
	if db.query(query) and cont != 0:
		print("simulaciones eliminadas del usuario ",cont)
	else: 
		print("error al eliminar el historial o no hay simulaciones")
		
	return cont
