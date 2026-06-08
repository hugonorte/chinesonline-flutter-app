import re

# Go enum
data = """
	PaisNaoInformado Country = iota // 0
	Afeganistao
	AfricaDoSul
	Albania
	Alemanha
	Andorra
	Angola
	AntiguaEBarbuda
	ArabiaSaudita
	Argelia
	Argentina
	Armenia
	Australia
	Austria
	Azerbaijao
	Bahamas
	Bangladesh
	Barbados
	Barein
	Belarus
	Belgica
	Belize
	Benin
	Bolivia
	BosniaEHerzegovina
	Botsuana
	Brasil
	Brunei
	Bulgaria
	BurkinaFaso
	Burundi
	Butao
	CaboVerde
	Camaroes
	Camboja
	Canada
	Catar
	Cazaquistao
	Chade
	Chile
	China
	Chipre
	Colombia
	Comores
	Congo
	CoreiaDoNorte
	CoreiaDoSul
	CostaDoMarfim
	CostaRica
	Croacia
	Cuba
	Dinamarca
	Djibuti
	Dominica
	Egito
	ElSalvador
	EmiradosArabesUnidos
	Equador
	Eritreia
	Eslovaquia
	Eslovenia
	Espanha
	EstadosUnidos
	Estonia
	Eswatini
	Etiopia
	Fiji
	Filipinas
	Finlandia
	Franca
	Gabao
	Gambia
	Gana
	Georgia
	Granada
	Grecia
	Guatemala
	Guiana
	Guine
	GuineBissau
	GuineEquatorial
	Haiti
	Honduras
	Hungria
	Iemen
	IlhasMarshall
	IlhasSalomao
	India
	Indonesia
	Ira
	Iraque
	Irlanda
	Islandia
	Israel
	Italia
	Jamaica
	Japao
	Jordania
	Kiribati
	Kuwait
	Laos
	Lesoto
	Letonia
	Libano
	Liberia
	Libia
	Liechtenstein
	Lituania
	Luxemburgo
	MacedoniaDoNorte
	Madagascar
	Malasia
	Malaui
	Maldivas
	Mali
	Malta
	Marrocos
	Mauricio
	Mauritania
	Mexico
	Micronesia
	Mocambique
	Moldavia
	Monaco
	Mongolia
	Montenegro
	Mianmar
	Namibia
	Nauru
	Nepal
	Nicaragua
	Niger
	Nigeria
	Noruega
	NovaZelandia
	Oma
	PaisesBaixos
	Palau
	Panama
	PapuaNovaGuine
	Paquistao
	Paraguai
	Peru
	Polonia
	Portugal
	Quenia
	Quirguistao
	ReinoUnido
	RepublicaCentroAfricana
	RepublicaCheca
	RepublicaDemocraticaDoCongo
	RepublicaDominicana
	Romenia
	Ruanda
	Russia
	Samoa
	SanMarino
	SantaLucia
	SaoCristovaoENevis
	SaoTomeEPrincipe
	SaoVicenteEGranadinas
	Seicheles
	Senegal
	SerraLeoa
	Servia
	Singapura
	Siria
	Somalia
	SriLanka
	Sudao
	SudaoDoSul
	Suecia
	Suica
	Suriname
	Tailandia
	Tajiquistao
	Tanzania
	TimorLeste
	Togo
	Tonga
	TrindadeETobago
	Tunisia
	Turcomenistao
	Turquia
	Tuvalu
	Ucrania
	Uganda
	Uruguai
	Uzbequistao
	Vanuatu
	Vaticano
	Venezuela
	Vietna
	Zambia
	Zimbabue
"""

# Simple map for flags.
flags = {
    "Afeganistao": ("Afeganistão", "🇦🇫"),
    "AfricaDoSul": ("África do Sul", "🇿🇦"),
    "Albania": ("Albânia", "🇦🇱"),
    "Alemanha": ("Alemanha", "🇩🇪"),
    "Andorra": ("Andorra", "🇦🇩"),
    "Angola": ("Angola", "🇦🇴"),
    "AntiguaEBarbuda": ("Antígua e Barbuda", "🇦🇬"),
    "ArabiaSaudita": ("Arábia Saudita", "🇸🇦"),
    "Argelia": ("Argélia", "🇩🇿"),
    "Argentina": ("Argentina", "🇦🇷"),
    "Armenia": ("Armênia", "🇦🇲"),
    "Australia": ("Austrália", "🇦🇺"),
    "Austria": ("Áustria", "🇦🇹"),
    "Azerbaijao": ("Azerbaijão", "🇦🇿"),
    "Bahamas": ("Bahamas", "🇧🇸"),
    "Bangladesh": ("Bangladesh", "🇧🇩"),
    "Barbados": ("Barbados", "🇧🇧"),
    "Barein": ("Barein", "🇧🇭"),
    "Belarus": ("Belarus", "🇧🇾"),
    "Belgica": ("Bélgica", "🇧🇪"),
    "Belize": ("Belize", "🇧🇿"),
    "Benin": ("Benin", "🇧🇯"),
    "Bolivia": ("Bolívia", "🇧🇴"),
    "BosniaEHerzegovina": ("Bósnia e Herzegovina", "🇧🇦"),
    "Botsuana": ("Botsuana", "🇧🇼"),
    "Brasil": ("Brasil", "🇧🇷"),
    "Brunei": ("Brunei", "🇧🇳"),
    "Bulgaria": ("Bulgária", "🇧🇬"),
    "BurkinaFaso": ("Burkina Faso", "🇧🇫"),
    "Burundi": ("Burundi", "🇧🇮"),
    "Butao": ("Butão", "🇧🇹"),
    "CaboVerde": ("Cabo Verde", "🇨🇻"),
    "Camaroes": ("Camarões", "🇨🇲"),
    "Camboja": ("Camboja", "🇰🇭"),
    "Canada": ("Canadá", "🇨🇦"),
    "Catar": ("Catar", "🇶🇦"),
    "Cazaquistao": ("Cazaquistão", "🇰🇿"),
    "Chade": ("Chade", "🇹🇩"),
    "Chile": ("Chile", "🇨🇱"),
    "China": ("China", "🇨🇳"),
    "Chipre": ("Chipre", "🇨🇾"),
    "Colombia": ("Colômbia", "🇨🇴"),
    "Comores": ("Comores", "🇰🇲"),
    "Congo": ("Congo", "🇨🇬"),
    "CoreiaDoNorte": ("Coreia do Norte", "🇰🇵"),
    "CoreiaDoSul": ("Coreia do Sul", "🇰🇷"),
    "CostaDoMarfim": ("Costa do Marfim", "🇨🇮"),
    "CostaRica": ("Costa Rica", "🇨🇷"),
    "Croacia": ("Croácia", "🇭🇷"),
    "Cuba": ("Cuba", "🇨🇺"),
    "Dinamarca": ("Dinamarca", "🇩🇰"),
    "Djibuti": ("Djibuti", "🇩🇯"),
    "Dominica": ("Dominica", "🇩🇲"),
    "Egito": ("Egito", "🇪🇬"),
    "ElSalvador": ("El Salvador", "🇸🇻"),
    "EmiradosArabesUnidos": ("Emirados Árabes Unidos", "🇦🇪"),
    "Equador": ("Equador", "🇪🇨"),
    "Eritreia": ("Eritreia", "🇪🇷"),
    "Eslovaquia": ("Eslováquia", "🇸🇰"),
    "Eslovenia": ("Eslovênia", "🇸🇮"),
    "Espanha": ("Espanha", "🇪🇸"),
    "EstadosUnidos": ("Estados Unidos", "🇺🇸"),
    "Estonia": ("Estônia", "🇪🇪"),
    "Eswatini": ("Eswatini", "🇸🇿"),
    "Etiopia": ("Etiópia", "🇪🇹"),
    "Fiji": ("Fiji", "🇫🇯"),
    "Filipinas": ("Filipinas", "🇵🇭"),
    "Finlandia": ("Finlândia", "🇫🇮"),
    "Franca": ("França", "🇫🇷"),
    "Gabao": ("Gabão", "🇬🇦"),
    "Gambia": ("Gâmbia", "🇬🇲"),
    "Gana": ("Gana", "🇬🇭"),
    "Georgia": ("Geórgia", "🇬🇪"),
    "Granada": ("Granada", "🇬🇩"),
    "Grecia": ("Grécia", "🇬🇷"),
    "Guatemala": ("Guatemala", "🇬🇹"),
    "Guiana": ("Guiana", "🇬🇾"),
    "Guine": ("Guiné", "🇬🇳"),
    "GuineBissau": ("Guiné-Bissau", "🇬🇼"),
    "GuineEquatorial": ("Guiné Equatorial", "🇬🇶"),
    "Haiti": ("Haiti", "🇭🇹"),
    "Honduras": ("Honduras", "🇭🇳"),
    "Hungria": ("Hungria", "🇭🇺"),
    "Iemen": ("Iêmen", "🇾🇪"),
    "IlhasMarshall": ("Ilhas Marshall", "🇲🇭"),
    "IlhasSalomao": ("Ilhas Salomão", "🇸🇧"),
    "India": ("Índia", "🇮🇳"),
    "Indonesia": ("Indonésia", "🇮🇩"),
    "Ira": ("Irã", "🇮🇷"),
    "Iraque": ("Iraque", "🇮🇶"),
    "Irlanda": ("Irlanda", "🇮🇪"),
    "Islandia": ("Islândia", "🇮🇸"),
    "Israel": ("Israel", "🇮🇱"),
    "Italia": ("Itália", "🇮🇹"),
    "Jamaica": ("Jamaica", "🇯🇲"),
    "Japao": ("Japão", "🇯🇵"),
    "Jordania": ("Jordânia", "🇯🇴"),
    "Kiribati": ("Kiribati", "🇰🇮"),
    "Kuwait": ("Kuwait", "🇰🇼"),
    "Laos": ("Laos", "🇱🇦"),
    "Lesoto": ("Lesoto", "🇱🇸"),
    "Letonia": ("Letônia", "🇱🇻"),
    "Libano": ("Líbano", "🇱🇧"),
    "Liberia": ("Libéria", "🇱🇷"),
    "Libia": ("Líbia", "🇱🇾"),
    "Liechtenstein": ("Liechtenstein", "🇱🇮"),
    "Lituania": ("Lituânia", "🇱🇹"),
    "Luxemburgo": ("Luxemburgo", "🇱🇺"),
    "MacedoniaDoNorte": ("Macedônia do Norte", "🇲🇰"),
    "Madagascar": ("Madagascar", "🇲🇬"),
    "Malasia": ("Malásia", "🇲🇾"),
    "Malaui": ("Malaui", "🇲🇼"),
    "Maldivas": ("Maldivas", "🇲🇻"),
    "Mali": ("Mali", "🇲🇱"),
    "Malta": ("Malta", "🇲🇹"),
    "Marrocos": ("Marrocos", "🇲🇦"),
    "Mauricio": ("Maurício", "🇲🇺"),
    "Mauritania": ("Mauritânia", "🇲🇷"),
    "Mexico": ("México", "🇲🇽"),
    "Micronesia": ("Micronésia", "🇫🇲"),
    "Mocambique": ("Moçambique", "🇲🇿"),
    "Moldavia": ("Moldávia", "🇲🇩"),
    "Monaco": ("Mônaco", "🇲🇨"),
    "Mongolia": ("Mongólia", "🇲🇳"),
    "Montenegro": ("Montenegro", "🇲🇪"),
    "Mianmar": ("Mianmar", "🇲🇲"),
    "Namibia": ("Namíbia", "🇳🇦"),
    "Nauru": ("Nauru", "🇳🇷"),
    "Nepal": ("Nepal", "🇳🇵"),
    "Nicaragua": ("Nicarágua", "🇳🇮"),
    "Niger": ("Níger", "🇳🇪"),
    "Nigeria": ("Nigéria", "🇳🇬"),
    "Noruega": ("Noruega", "🇳🇴"),
    "NovaZelandia": ("Nova Zelândia", "🇳🇿"),
    "Oma": ("Omã", "🇴🇲"),
    "PaisesBaixos": ("Países Baixos", "🇳🇱"),
    "Palau": ("Palau", "🇵🇼"),
    "Panama": ("Panamá", "🇵🇦"),
    "PapuaNovaGuine": ("Papua-Nova Guiné", "🇵🇬"),
    "Paquistao": ("Paquistão", "🇵🇰"),
    "Paraguai": ("Paraguai", "🇵🇾"),
    "Peru": ("Peru", "🇵🇪"),
    "Polonia": ("Polônia", "🇵🇱"),
    "Portugal": ("Portugal", "🇵🇹"),
    "Quenia": ("Quênia", "🇰🇪"),
    "Quirguistao": ("Quirguistão", "🇰🇬"),
    "ReinoUnido": ("Reino Unido", "🇬🇧"),
    "RepublicaCentroAfricana": ("República Centro-Africana", "🇨🇫"),
    "RepublicaCheca": ("República Checa", "🇨🇿"),
    "RepublicaDemocraticaDoCongo": ("República Democrática do Congo", "🇨🇩"),
    "RepublicaDominicana": ("República Dominicana", "🇩🇴"),
    "Romenia": ("Romênia", "🇷🇴"),
    "Ruanda": ("Ruanda", "🇷🇼"),
    "Russia": ("Rússia", "🇷🇺"),
    "Samoa": ("Samoa", "🇼🇸"),
    "SanMarino": ("San Marino", "🇸🇲"),
    "SantaLucia": ("Santa Lúcia", "🇱🇨"),
    "SaoCristovaoENevis": ("São Cristóvão e Nevis", "🇰🇳"),
    "SaoTomeEPrincipe": ("São Tomé e Príncipe", "🇸🇹"),
    "SaoVicenteEGranadinas": ("São Vicente e Granadinas", "🇻🇨"),
    "Seicheles": ("Seicheles", "🇸🇨"),
    "Senegal": ("Senegal", "🇸🇳"),
    "SerraLeoa": ("Serra Leoa", "🇸🇱"),
    "Servia": ("Sérvia", "🇷🇸"),
    "Singapura": ("Singapura", "🇸🇬"),
    "Siria": ("Síria", "🇸🇾"),
    "Somalia": ("Somália", "🇸🇴"),
    "SriLanka": ("Sri Lanka", "🇱🇰"),
    "Sudao": ("Sudão", "🇸🇩"),
    "SudaoDoSul": ("Sudão do Sul", "🇸🇸"),
    "Suecia": ("Suécia", "🇸🇪"),
    "Suica": ("Suíça", "🇨🇭"),
    "Suriname": ("Suriname", "🇸🇷"),
    "Tailandia": ("Tailândia", "🇹🇭"),
    "Tajiquistao": ("Tajiquistão", "🇹🇯"),
    "Tanzania": ("Tanzânia", "🇹🇿"),
    "TimorLeste": ("Timor-Leste", "🇹🇱"),
    "Togo": ("Togo", "🇹🇬"),
    "Tonga": ("Tonga", "🇹🇴"),
    "TrindadeETobago": ("Trindade e Tobago", "🇹🇹"),
    "Tunisia": ("Tunísia", "🇹🇳"),
    "Turcomenistao": ("Turcomenistão", "🇹🇲"),
    "Turquia": ("Turquia", "🇹🇷"),
    "Tuvalu": ("Tuvalu", "🇹🇻"),
    "Ucrania": ("Ucrânia", "🇺🇦"),
    "Uganda": ("Uganda", "🇺🇬"),
    "Uruguai": ("Uruguai", "🇺🇾"),
    "Uzbequistao": ("Uzbequistão", "🇺🇿"),
    "Vanuatu": ("Vanuatu", "🇻🇺"),
    "Vaticano": ("Vaticano", "🇻🇦"),
    "Venezuela": ("Venezuela", "🇻🇪"),
    "Vietna": ("Vietnã", "🇻🇳"),
    "Zambia": ("Zâmbia", "🇿🇲"),
    "Zimbabue": ("Zimbábue", "🇿🇼"),
}

output = "class Country {\n  final int id;\n  final String name;\n  final String flag;\n\n  const Country(this.id, this.name, this.flag);\n}\n\nconst List<Country> countries = [\n"

lines = data.strip().split("\n")
count = 0
for line in lines:
    line = line.strip()
    if not line or line.startswith("//"):
        continue
    # Extract name
    parts = line.split()
    key = parts[0]
    
    if key == "PaisNaoInformado":
        output += f"  Country(0, 'Não Informado', '❓'),\n"
        count += 1
        continue
    
    name, flag = flags.get(key, (key, "🏳️"))
    output += f"  Country({count}, '{name}', '{flag}'),\n"
    count += 1

output += "];\n"

with open("/mnt/sda2/sandbox/chinesonline/app/lib/features/auth/domain/country.dart", "w") as f:
    f.write(output)

print("country.dart generated successfully!")
