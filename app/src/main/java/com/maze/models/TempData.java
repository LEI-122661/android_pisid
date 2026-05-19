package com.maze.models;

import com.google.gson.annotations.SerializedName;

public class TempData {
    @SerializedName("IDTemperatura")
    private int id;

    @SerializedName("IDMensagem")
    private Integer idMensagem;

    @SerializedName("Hora")
    private String hora;

    @SerializedName("Temperatura")
    private float value;

    public TempData() {}

    public int getID() { return id; }
    public void setID(int id) { this.id = id; }

    public float getValue() { return value; }
    public void setValue(float value) { this.value = value; }

    public Integer getIdMensagem() { return idMensagem; }
    public void setIdMensagem(Integer idMensagem) { this.idMensagem = idMensagem; }

    public String getHora() { return hora; }
    public void setHora(String hora) { this.hora = hora; }
}
