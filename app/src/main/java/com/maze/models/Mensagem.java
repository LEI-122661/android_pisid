package com.maze.models;

import com.google.gson.annotations.SerializedName;

public class Mensagem {
    @SerializedName("ID")
    private int id;

    @SerializedName("IDSimulacao")
    private Integer idSimulacao;

    @SerializedName("Hora")
    private String hora;

    @SerializedName("Sala")
    private Integer sala;

    @SerializedName("Sensor")
    private String sensor;

    @SerializedName("Leitura")
    private Double leitura;

    @SerializedName("Msg")
    private String msg;

    @SerializedName("HoraEscrita")
    private String horaEscrita;

    public Mensagem() {}

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Integer getIdSimulacao() { return idSimulacao; }
    public void setIdSimulacao(Integer idSimulacao) { this.idSimulacao = idSimulacao; }

    public String getHora() { return hora; }
    public void setHora(String hora) { this.hora = hora; }

    public Integer getSala() { return sala; }
    public void setSala(Integer sala) { this.sala = sala; }

    public String getSensor() { return sensor; }
    public void setSensor(String sensor) { this.sensor = sensor; }

    public Double getLeitura() { return leitura; }
    public void setLeitura(Double leitura) { this.leitura = leitura; }

    public String getMsg() { return msg; }
    public void setMsg(String msg) { this.msg = msg; }

    public String getHoraEscrita() { return horaEscrita; }
    public void setHoraEscrita(String horaEscrita) { this.horaEscrita = horaEscrita; }

    // Legacy support for Fragment display
    public String getDate() { return hora; }
    public String getText() { return msg; }
    public String getValue() { return leitura != null ? String.valueOf(leitura) : ""; }

    public int getMessagetype() {
        if (sensor == null) return 0;
        if (sensor.equalsIgnoreCase("Temp")) return 1;
        if (sensor.equalsIgnoreCase("Som")) return 2;
        return 0;
    }
}
