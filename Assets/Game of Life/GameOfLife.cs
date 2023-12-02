using System;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
public class GameOfLife : MonoBehaviour
{
    // Scripti voi vaihtaa inspectorissa dropdown valikon avulla aloitus seediä.
    public enum GameInit
    {
        RPentomino,
        Acorn,
        GosperGun,
        FullTexture
    }
    [SerializeField] private GameInit Seed;
    // Scriptin kuuluisi päivittää ulkoisen planen materiaalia vaihtamalla sen tekstuuria.
    [SerializeField] private Material PlaneMaterial;
    // Simuloitavan solun väriä tulisi voida muuttaa ennen simulaation aloitusta.
    [SerializeField] private Color CellCol;
    [SerializeField] private ComputeShader Simulator;
    // Pelin ollessa käynnissä, scriptin tulisi ylläpitää aikaväliä, jona simulaatiota päivitetään,
    // eli kuinka nopeasti uusi generaatio tapahtuu.
    [SerializeField, Range(0f, 2f)] private float UpdateInterval;
    private float NextUpdate = 2f;
    // Tekstuurien koko on 512x512.
    private static readonly Vector2Int TexSize = new Vector2Int(512, 512);
    private RenderTexture State1;
    private RenderTexture State2;
    // Scriptillä on 2 vaihetta, update1 ja update2.
    // Scriptin kuuluisi voida vaihdella niiden välillä.
    // Scriptin tulisi myös pitää kirjaa, kummassa vaiheessa simulaatiota ollaan,
    // ja päättää sen mukaan, kumpi vaihe suorittaa.
    private bool IsState1;
    private static int Update1Kernel;
    private static int Update2Kernel;

    private static int RPentominoKernel;
    private static int AcornKernel;
    private static int GunKernel;
    private static int FullKernel;

    // Property ID
    private static readonly int BaseMap = Shader.PropertyToID("_BaseMap");
    private static readonly int CellColour = Shader.PropertyToID("CellColour");
    private static readonly int TextureSize = Shader.PropertyToID("TextureSize");
    private static readonly int State1Tex = Shader.PropertyToID("State1");
    private static readonly int State2Tex = Shader.PropertyToID("State2");

    void Start()
    {
        // Scriptin tulisi aluksi, kun peli käynnistetään, luoda 2 RenderTexturea
        // default LDR asetuksilla, point filterillä ja enableRandomWrite = true.
        State1 = new RenderTexture(TexSize.x, TexSize.y, 0, DefaultFormat.LDR)
        {
            wrapMode = TextureWrapMode.Repeat,
            filterMode = FilterMode.Point,
            enableRandomWrite = true
        };
        State1.Create();

        State2 = new RenderTexture(TexSize.x, TexSize.y, 0, DefaultFormat.LDR)
        {
            wrapMode = TextureWrapMode.Repeat,
            filterMode = FilterMode.Point,
            enableRandomWrite = true
        };
        State2.Create();

        // Sen tulisi myös löytää Compute Shaderin kaikki kernelit tässä vaiheessa.
        Update1Kernel = Simulator.FindKernel("Update1");
        Update2Kernel = Simulator.FindKernel("Update2");

        // vaihtoehtoisesti:

        int seedKernel;
        seedKernel = Seed switch
        {
            GameInit.RPentomino => Simulator.FindKernel("InitRPentomino"),
            GameInit.Acorn => Simulator.FindKernel("InitAcorn"),
            GameInit.GosperGun => Simulator.FindKernel("InitGun"),
            GameInit.FullTexture => Simulator.FindKernel("InitFullTexture"),
            _ => 0
        };

        // Compute Shaderiin tulisi liittää tässä vaiheessa kaikkiin kerneleihin tarvittavat tekstuurit
        // ja muut fieldit jotka eivät päivity suorituksen aikana.
        Simulator.SetTexture(Update1Kernel, State1Tex, State1);
        Simulator.SetTexture(Update1Kernel, State2Tex, State2);
     

        Simulator.SetTexture(Update2Kernel, State1Tex, State1);
        Simulator.SetTexture(Update2Kernel, State2Tex, State2);
        

        // Vaihtoehtoisesti:
        Simulator.SetTexture(seedKernel, State1Tex, State1);
        Simulator.SetTexture(seedKernel, State2Tex, State2);
        //Simulator.SetTexture(seedKernel, BaseMap, State1);

        Simulator.SetVector(CellColour, CellCol);

        // bonus
        Simulator.SetVector(TextureSize, new Vector4(TexSize.x, TexSize.y));

        // Scriptin tulisi myös tässä vaiheessa päättää,
        // millä aloitus seedillä simulaatio aloitetaan, ja initialisoida simulaatio.

        Simulator.Dispatch(seedKernel, TexSize.x / 8, TexSize.y / 8, 1);

        Simulator.SetTexture(Update1Kernel, BaseMap, State1);
        Simulator.SetTexture(Update2Kernel, BaseMap, State2);
    }

    void Update()
    {
        // Pelin ollessa käynnissä, scriptin tulisi ylläpitää aikaväliä, jona simulaatiota päivitetään,
        // eli kuinka nopeasti uusi generaatio tapahtuu.
        if (Time.time < NextUpdate) return;
        // Scriptin tulisi myös pitää kirjaa, kummassa vaiheessa simulaatiota ollaan,
        // ja päättää sen mukaan, kumpi vaihe suorittaa.
        IsState1 = !IsState1;

        // Scriptin kuuluisi myös päivittää esitykseen käytetyn materiaalin tekstuuria
        // vaiheen mukaan (flipbook).
        Simulator.Dispatch(Update1Kernel, TexSize.x / 8, TexSize.y / 8, 1);
        Simulator.Dispatch(Update2Kernel, TexSize.x / 8, TexSize.y / 8, 1);
        //PlaneMaterial.SetTexture(BaseMap, State1);
        PlaneMaterial.SetTexture(BaseMap, IsState1 ? State1 : State2);

        NextUpdate = Time.time + UpdateInterval;
    }

    // Kun scripti tuhotaan tai disabloidaan,
    // sen kuuluisi vapauttaa render texture muuttujat muistista.
    private void OnDisable()
    {
        State1.Release();
        State2.Release();
    }
    private void OnDestroy()
    {
        State1.Release();
        State2.Release();
    }
}