package com.maze.models;

import com.google.gson.annotations.SerializedName;

public class RoomData {
    @SerializedName("IDJogo")
    private int idJogo;

    @SerializedName("IDSimulacao")
    private Integer idSimulacao;

    @SerializedName("Sala")
    private int sala;

    @SerializedName("NumeroMarsamisOdd")
    private int numeroMarsamisOdd;

    @SerializedName("NumeroMarsamisEven")
    private int numeroMarsamisEven;

    @SerializedName("GatilhosUsados")
    private int gatilhosUsados;

    public RoomData() {}

    public int getSalaInt() { return sala; }
    public int getNumeroMarsamisOdd() { return numeroMarsamisOdd; }
    public int getNumeroMarsamisEven() { return numeroMarsamisEven; }
    public int getGatilhosUsados() { return gatilhosUsados; }

    // Legacy support for Fragments
    public String getRoom() { return String.valueOf(sala); }
    public String getNumberEven() { return String.valueOf(numeroMarsamisEven); }
    public String getNumberOdd() { return String.valueOf(numeroMarsamisOdd); }
}
