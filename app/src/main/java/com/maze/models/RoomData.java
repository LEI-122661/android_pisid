package com.maze.models;

import com.google.gson.annotations.SerializedName;

public class RoomData {
    @SerializedName("Sala")
    private int sala;

    @SerializedName("NumeroMarsamisEven")
    private int numeroMarsamisEven;

    @SerializedName("NumeroMarsamisOdd")
    private int numeroMarsamisOdd;

    @SerializedName("GatilhosUsados")
    private int gatilhosUsados;

    @SerializedName("IDSimulacao")
    private Integer idSimulacao;

    @SerializedName("IDJogo")
    private int idJogo;

    public RoomData() {}

    public int getSala() { return sala; }
    public void setSala(int sala) { this.sala = sala; }

    public int getNumeroMarsamisEven() { return numeroMarsamisEven; }
    public void setNumeroMarsamisEven(int numeroMarsamisEven) { this.numeroMarsamisEven = numeroMarsamisEven; }

    public int getNumeroMarsamisOdd() { return numeroMarsamisOdd; }
    public void setNumeroMarsamisOdd(int numeroMarsamisOdd) { this.numeroMarsamisOdd = numeroMarsamisOdd; }

    public int getGatilhosUsados() { return gatilhosUsados; }
    public void setGatilhosUsados(int gatilhosUsados) { this.gatilhosUsados = gatilhosUsados; }

    public Integer getIdSimulacao() { return idSimulacao; }
    public void setIdSimulacao(Integer idSimulacao) { this.idSimulacao = idSimulacao; }

    public int getIdJogo() { return idJogo; }
    public void setIdJogo(int idJogo) { this.idJogo = idJogo; }

    // Legacy support for fragment
    public String getRoom() { return String.valueOf(sala); }
    public String getNumberEven() { return String.valueOf(numeroMarsamisEven); }
    public String getNumberOdd() { return String.valueOf(numeroMarsamisOdd); }
}
