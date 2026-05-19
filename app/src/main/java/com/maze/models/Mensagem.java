package com.maze.models;

import com.google.gson.annotations.SerializedName;

public class Mensagem {
    @SerializedName("ID")
    private int id;

    @SerializedName("IDSimulacao")
    private int idSimulacao;

    @SerializedName("Sensor")
    private String sensor;

    @SerializedName("TipoAlerta")
    private String tipoAlerta;

    @SerializedName("Valor")
    private Double valor;

    @SerializedName("DataAlerta")
    private String dataAlerta;

    @SerializedName("Descricao")
    private String descricao;

    public Mensagem() {}

    // Getters
    public int getId() { return id; }
    public String getSensor() { return sensor; }
    public String getTipoAlerta() { return tipoAlerta; }
    public Double getValor() { return valor; }
    public String getDataAlerta() { return dataAlerta; }
    public String getDescricao() { return descricao; }

    // Legacy support for display in MazeMessagesFragment
    public String getDate() { return dataAlerta; }
    public String getText() { return descricao; }
    public String getValue() { return valor != null ? String.valueOf(valor) : ""; }

    public int getMessagetype() {
        if (tipoAlerta == null) return 0;
        // Example logic for colors based on TipoAlerta
        if (tipoAlerta.equalsIgnoreCase("Critico")) return 3; // Red
        if (tipoAlerta.equalsIgnoreCase("Aviso")) return 2;   // Green
        return 1; // Blue
    }
}
