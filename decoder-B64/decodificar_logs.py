#!/usr/bin/env python3
import os
import re
import json
import base64
import gzip

# ============================================================================
# SCRIPT PARA DECODIFICAR CADENAS BASE64+GZIP DESDE EXPORTES DE TELEGRAM
# SIN MODIFICAR LA LÓGICA ORIGINAL. SOLO SE HAN AÑADIDO/ACTUALIZADO COMENTARIOS
# EN MAYÚSCULAS PARA EXPLICAR CADA PASO DEL PROCESO.
# ============================================================================

# NOMBRES FIJOS DE LOS FICHEROS DE ENTRADA/SALIDA
JSON_FILE = "entrada.json"
HTML_FILE = "entrada.html"
OUTPUT_FILE = "salida.txt"


def decode_base64_gzip(b64_text: str) -> str:
    """
    FUNCION: DECODIFICA UNA CADENA BASE64 QUE CONTIENE UN GZIP.
    - LIMPIA ESPACIOS EN BLANCO.
    - SI ESTÁ VACÍO, DEVUELVE CADENA VACÍA.
    - INTENTA DECODIFICAR BASE64 Y DESCOMPRIMIR GZIP.
    - DEVUELVE TEXTO UTF-8 O MENSAJE DE ERROR FORMATEADO.
    """
    b64_text = b64_text.strip()
    if not b64_text:
        return ""
    try:
        gz_bytes = base64.b64decode(b64_text)
        text = gzip.decompress(gz_bytes).decode("utf-8", errors="replace")
        return text
    except Exception as e:
        return f"[ERROR] No se pudo decodificar: {b64_text[:50]}... ({e})"


def process_json(path: str) -> list[str]:
    """
    LEE EL JSON EXPORTADO (COMO EL QUE ME PASASTE) Y EXTRAE TODOS LOS TEXTOS
    QUE SEAN CADENAS BASE64-GZIP (EMPIEZAN POR H4SI).
    DEVUELVE UNA LISTA DE TEXTOS YA DECODIFICADOS EN EL ORDEN EN QUE APARECEN.
    """
    # ABRIR Y CARGAR EL JSON DE ENTRADA
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    decoded_lines: list[str] = []

    # OBTENER LA LISTA DE MENSAJES (SI NO EXISTE, LISTA VACÍA)
    messages = data.get("messages", [])
    for msg in messages:
        # ACCEDER AL CAMPO "text"
        text_field = msg.get("text")

        # EL EXPORT DE TELEGRAM A VECES PONE "text": "CADENA..."
        # Y OTRAS VECES "text": [ {type:..., text:"..."} , ...]
        candidates: list[str] = []

        if isinstance(text_field, str):
            # CASO 1: EL CAMPO ES DIRECTAMENTE UNA CADENA
            candidates.append(text_field)
        elif isinstance(text_field, list):
            # CASO 2: ES UNA LISTA; EXTRAER SOLO LAS PARTES QUE SEAN TEXTO PLANO
            for part in text_field:
                if isinstance(part, dict):
                    t = part.get("text")
                    if isinstance(t, str):
                        candidates.append(t)

        # RECORRER POSIBLES CANDIDATOS Y FILTRAR LOS QUE PARECEN BASE64+GZIP
        for cand in candidates:
            cand = cand.strip()
            # NUESTROS LOGS VIENEN ASÍ: EMPIEZAN POR "H4SI"
            if cand.startswith("H4sI"):
                decoded = decode_base64_gzip(cand)
                if decoded:
                    decoded_lines.append(decoded)

    return decoded_lines


def process_html(path: str) -> list[str]:
    """
    LEE EL HTML EXPORTADO Y BUSCA TODAS LAS CADENAS QUE PAREZCAN
    NUESTRO BASE64-GZIP (H4SI...).
    DEVUELVE UNA LISTA DE TEXTOS DECODIFICADOS EN EL ORDEN EN QUE APARECEN.
    """
    # LEER COMPLETO EL CONTENIDO HTML
    with open(path, "r", encoding="utf-8") as f:
        html = f.read()

    # PATRÓN MUY DIRECTO: TODO LO QUE EMPIECE POR H4SI Y SIGA CON BASE64
    # HASTA QUE ENCUENTRE UN CARÁCTER QUE NO SEA BASE64 (= INCLUIDO)
    pattern = re.compile(r"(H4sIA[0-9A-Za-z+/=]+)")
    decoded_lines: list[str] = []

    # ITERAR TODAS LAS OCURRENCIAS Y DECODIFICARLAS
    for match in pattern.finditer(html):
        b64_text = match.group(1).strip()
        decoded = decode_base64_gzip(b64_text)
        if decoded:
            decoded_lines.append(decoded)

    return decoded_lines


def main():
    # DECIDIR QUÉ ENTRADA USAR EN FUNCIÓN DE LO QUE EXISTA EN LA CARPETA
    input_path = None
    mode = None  # "JSON" O "HTML"

    if os.path.exists(JSON_FILE):
        input_path = JSON_FILE
        mode = "json"
    elif os.path.exists(HTML_FILE):
        input_path = HTML_FILE
        mode = "html"
    else:
        # NO SE ENCONTRÓ NINGUNA ENTRADA VÁLIDA
        print(f"No encontré {JSON_FILE} ni {HTML_FILE} en esta carpeta.")
        return

    # PROCESAR SEGÚN EL MODO DETECTADO
    if mode == "json":
        decoded_lines = process_json(input_path)
    else:
        decoded_lines = process_html(input_path)

    # ESCRIBIR SALIDA EN FICHERO DE TEXTO, UNA LÍNEA POR MENSAJE DECODIFICADO
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f_out:
        for line in decoded_lines:
            f_out.write(line)
            if not line.endswith("\n"):
                f_out.write("\n")

    # MENSAJE FINAL DE RESUMEN
    print(f"Procesado {input_path} -> {OUTPUT_FILE}")


if __name__ == "__main__":
    # PUNTO DE ENTRADA DEL SCRIPT
    main()
