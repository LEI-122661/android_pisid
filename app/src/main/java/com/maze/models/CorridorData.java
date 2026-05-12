package com.maze.models;

import com.google.gson.annotations.SerializedName;

public class CorridorData {
    @SerializedName("Sala")
    private int sala;

    @SerializedName("NumeroMarsamisEven")
    private int numeroMarsamisEven;

    @SerializedName("NumeroMarsamisOdd")
    private int numeroMarsamisOdd;

    public CorridorData(int sala, int numeroMarsamisEven, int numeroMarsamisOdd) {
        this.sala = sala;
        this.numeroMarsamisEven = numeroMarsamisEven;
        this.numeroMarsamisOdd = numeroMarsamisOdd;
    }

    public int getSala() { return sala; }
    public int getNumeroMarsamisEven() { return numeroMarsamisEven; }
    public int getNumeroMarsamisOdd() { return numeroMarsamisOdd; }

    public void setSala(int sala) { this.sala = sala; }
    public void setNumeroMarsamisEven(int numeroMarsamisEven) { this.numeroMarsamisEven = numeroMarsamisEven; }
    public void setNumeroMarsamisOdd(int numeroMarsamisOdd) { this.numeroMarsamisOdd = numeroMarsamisOdd; }

    // Legacy support
    public String getRoom() { return String.valueOf(sala); }
    public int getNumberEven() { return numeroMarsamisEven; }
    public int getNumberOdd() { return numeroMarsamisOdd; }
}
