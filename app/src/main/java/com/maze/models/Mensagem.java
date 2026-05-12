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

    @SerializedName("TipoAlerta")
    private String tipoAlerta;

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

    public String getTipoAlerta() { return tipoAlerta; }
    public void setTipoAlerta(String tipoAlerta) { this.tipoAlerta = tipoAlerta; }

    public String getMsg() { return msg; }
    public void setMsg(String msg) { this.msg = msg; }

    public String getHoraEscrita() { return horaEscrita; }
    public void setHoraEscrita(String horaEscrita) { this.horaEscrita = horaEscrita; }

    // Helper for legacy code
    public String getDate() { return hora; }
    public String getText() { return msg; }
    public String getValue() { return leitura != null ? String.valueOf(leitura) : ""; }

    public int getMessagetype() {
        if (tipoAlerta == null) return 0;
        if (tipoAlerta.equals("S")) return 1;
        return 0;
    }
}
