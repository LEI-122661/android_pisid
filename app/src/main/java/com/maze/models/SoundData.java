package com.maze.models;

import com.google.gson.annotations.SerializedName;

public class SoundData {
    @SerializedName("IDSom")
    private int id;

    @SerializedName("IDMensagem")
    private Integer idMensagem;

    @SerializedName("Hora")
    private String hora;

    @SerializedName("Som")
    private float value;

    public SoundData() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public float getValue() { return value; }
    public void setValue(float value) { this.value = value; }

    public Integer getIdMensagem() { return idMensagem; }
    public void setIdMensagem(Integer idMensagem) { this.idMensagem = idMensagem; }

    public String getHora() { return hora; }
    public void setHora(String hora) { this.hora = hora; }
}
