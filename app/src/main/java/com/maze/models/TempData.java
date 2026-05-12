package com.maze.models;

import com.google.gson.annotations.SerializedName;

public class TempData {

    @SerializedName("IDTemperatura")
    private int idTemperatura;

    @SerializedName("IDMensagem")
    private Integer idMensagem;

    @SerializedName("Hora")
    private String hora;

    @SerializedName("Temperatura")
    private float temperatura;

    public TempData() {}

    public int getIdTemperatura() { return idTemperatura; }
    public void setIdTemperatura(int idTemperatura) { this.idTemperatura = idTemperatura; }

    public Integer getIdMensagem() { return idMensagem; }
    public void setIdMensagem(Integer idMensagem) { this.idMensagem = idMensagem; }

    public String getHora() { return hora; }
    public void setHora(String hora) { this.hora = hora; }

    public float getTemperatura() { return temperatura; }
    public void setTemperatura(float temperatura) { this.temperatura = temperatura; }

    // Legacy support
    public int getID() { return idTemperatura; }
    public float getValue() { return temperatura; }
}
