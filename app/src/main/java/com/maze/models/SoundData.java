package com.maze.models;

import com.google.gson.annotations.SerializedName;

public class SoundData {

    @SerializedName("IDSom")
    private int idSom;

    @SerializedName("IDMensagem")
    private Integer idMensagem;

    @SerializedName("Hora")
    private String hora;

    @SerializedName("Som")
    private float som;

    public SoundData() {}

    public int getIdSom() { return idSom; }
    public void setIdSom(int idSom) { this.idSom = idSom; }

    public Integer getIdMensagem() { return idMensagem; }
    public void setIdMensagem(Integer idMensagem) { this.idMensagem = idMensagem; }

    public String getHora() { return hora; }
    public void setHora(String hora) { this.hora = hora; }

    public float getSom() { return som; }
    public void setSom(float som) { this.som = som; }

    // Legacy support
    public int getId() { return idSom; }
    public float getValue() { return som; }
}
