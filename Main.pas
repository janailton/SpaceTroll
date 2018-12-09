{****************************************************************************
 *                      SPACETROLL 2006                                     *
 *                         08/07/2006                                       *
 *   Autor : José Janailton <josejanailton@gmail.com>                       *
 *   Elaboração das naves: José de Souza alves e José Janailton da Silva    *
 *                                                                          *
 *       Este projeto é Opensource e está submetido aos termos da GNU GPL.  *
 *   Isto significa que você pode distribuir este código, mas deve manter   *
 *   o nome do autor, mesmo se fizer alterações deve citar  nome do autor   *
 *   e colaboradores.                                                       *
 *       Como Opensource o autor não dá garantias, seja  de manutenção,     *
 *  compatibilidade ou qualquer outro tipo deste código bem como se este    *
 *  for alterado indevidamente.                                             *
 *                                                                          *
 ****************************************************************************}


 unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,DXClass, DXDraws, DXInput, DXSprite, DXSounds, ExtCtrls,MMSystem,
  MPlayer, StdCtrls;




const
  DXInputButton = [isButton1, isButton2, isButton3,
    isButton4, isButton5, isButton6, isButton7, isButton8, isButton9, isButton10, isButton11,
    isButton12, isButton13, isButton14, isButton15, isButton16, isButton17, isButton18,
    isButton19, isButton20, isButton21, isButton22, isButton23, isButton24, isButton25,
    isButton26, isButton27, isButton28, isButton29, isButton30, isButton31, isButton32];



type

  TCena= (jogo,Abertura,GameOver,Vitoria);

  TFormTroll = class(TDXForm)
    TelaDX: TDXDraw; // Tela Pricipal
    SpriteEngine: TDXSpriteEngine;
    DXTimer1: TDXTimer;
    ImageList: TDXImageList;
    DXInput: TDXInput;// Mapeia teclado e joystic
    Logo: TTimer;
    SpriteEngine2: TDXSpriteEngine;
    ImageList2: TDXImageList;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure DXTimer1Timer(Sender: TObject; LagCount: Integer);// Loop Principal
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LogoTimer(Sender: TObject);
    procedure TelaDXInitialize(Sender: TObject);
    procedure TelaDXFinalize(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    key: word;
    Pshift: TShiftState;
    ALagCount: Integer;
  public
    // Estado do jogo
    Cena:TCena;
    MP1,MP2: TMediaplayer;
    Procedure Inicializa_Inimigo;
    Procedure Inicializa_Nave_Principal;
    Procedure TelaApresentacao;
    Procedure RodaJogo;
    Procedure _GameOver;
    Procedure _Vitoria;
    Procedure Mostra_Erro(Sender: TObject; E: Exception);
    Procedure MediaPlayerNotify(Sender:TObject);
  end;

var
  FormTroll: TFormTroll;
  SMsg: Boolean=False;// serve para verificar se pode escrever a mensagem "Aperte Start"





  implementation

uses Naves, DModule;

{$R *.dfm}






{=====================================================}
procedure TFormTroll.FormCreate(Sender: TObject);
 var
  i,j: integer;
begin

  Application.OnException:=Mostra_Erro;
  Randomize;

  // Sempre inicialize o DXDraw assim...
  ImageList.Items.MakeColorTable;
  TelaDX.ColorTable := ImageList.Items.ColorTable;
  TelaDX.DefColorTable := ImageList.Items.ColorTable;
  TelaDX.UpdatePalette;

  MP1:=TMediaplayer.Create(Self);
  MP1.Parent:=Self;
  MP1.Visible:=False;
  MP1.OnNotify:=Self.MediaPlayerNotify;
  MP1.FileName:='Star_Wars.wav';
  MP1.Open;
  Mp1.Play;
// ExecuteSoundWave(PChar('star_wars'));
  Sleep(1000);






  // Aqui é configurado o mapa do jogo
  with TBackgroundSprite.Create(SpriteEngine.Engine) do
    begin

      SetMapSize(8, 8000); // o mapa tem 8 figuras na horizontal e 8000 na vertical
      Image := ImageList.Items.Find('Espaco1');
      Collisioned := False;
      Z:=-20;
      Tile := false;
      {
      for i:= 0 to MapHeight-1 do
      for j:= 0 to MapWidth-1 do
          begin
           // if Random(40)<3 then
              Chips[i,j]:=-1;
           // else
           //   Chips[i,j]:=1;
           CollisionMap [i,j] := false;
          End; }
      Y:=-8000;// a janela do mapa é colocado na posição -8000

  end;

  // Esta rotina insere os planetas
  for i:= 15 downto -3999 do
        for j:= -1 to 15 do
        begin
            if Random(40)=3 then
               with TImageSprite.Create(SpriteEngine.Engine) do
                    begin
                      Image:=ImageList.Items.Find('Espaco2');
                      Width:=image.Width;
                      height:=Image.Height;
                      pixelcheck:=false;
                      Collisioned := False;;
                      x:=j*32+16;
                      y:= i*32+16;
                      Z := 0;
                      Tile := False;
                    end;

               if Random(20)=11 then
               with TImageSprite.Create(SpriteEngine.Engine) do
                    begin
                      Image:=ImageList.Items.Find('Espaco3');
                      Width:=image.Width;
                      height:=Image.Height;
                      pixelcheck:=false;
                      Collisioned := False;;
                      x:=j*40+16;
                      y:= i*40+16;
                      Z := 0;
                      Tile := False;
                    end;




   end;
  // Aqui é decidido qual  tela será exibida primeiro

  key:=VK_F4;
  FormKeyDown(sender,key,Pshift);
end;


   // Loop Principal do jogo
{=========================================================}

procedure TFormTroll.DXTimer1Timer(Sender: TObject; LagCount: Integer);
begin
if not TelaDX.CanDraw then Exit;
ALagCount:=LagCount; // esta é a velocidade de colisões das naves
DXInput.Update; // Ataliza a lista de teclas pressionadas
// Qual estado do jogo Exibir?
  Case Cena of
        Jogo:RodaJogo;
        Abertura:TelaApresentacao;
        GameOver:_GameOver;
        Vitoria:_Vitoria;
     end;

TelaDX.Flip;
end;

  //Muda o Tipo de tela  Full_Screen <--->Normal
{========================================================}

procedure TFormTroll.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
 if (Key=VK_RETURN) and ((cena=GameOver) or (Cena=Vitoria)) then Close;
 if (Key=VK_ESCAPE) then close;
 if Key=VK_F4 then
   begin
    //É necessario "desligar" o DXDraw para alterar o modo de video
    TelaDX.Finalize;

    if doFullScreen in TelaDX.Options then
    begin
      // Restaura a janela
      RestoreWindow;
      TelaDX.Width:=630;
      TelaDX.Height:=450;
      FormTroll.Width:=640;
      FormTroll.Height:=480;
      TelaDX.Display.Width := 480;
      TelaDX.Display.Height := 640;
      TelaDX.Display.BitCount := 16;
      TelaDX.Cursor := crDefault;
      BorderStyle := bsSingle;
      TelaDX.Options := TelaDX.Options - [doFullScreen];
    end else
    begin
      //Muda o modo da tela para 640x480 pixels em fullscreen
      StoreWindow;
      FormTroll.Width:=640;
      FormTroll.Height:=480;
      TelaDX.Width:=640;
      TelaDX.Height:=480;
      TelaDX.Cursor := crNone;     //   ____________________________
      BorderStyle := bsNone;      //    |                           |
      TelaDX.Display.Width := 640; //   | 640x480 pixels FullScreen |
      TelaDX.Display.Height := 480;//   |       16 Bits de cor      |
      TelaDX.Display.BitCount := 16; // |___________________________|
      TelaDX.Options := TelaDX.Options + [doFullScreen];
    end;
    // Agora, inicializa o DXDraw novamente com o novo modo de video
    TelaDX.Initialize;
  end;
end;

{======================================================}

procedure TFormTroll.RodaJogo;
begin

 if not TelaDX.CanDraw then Exit;
 Logo.Enabled:=False;

  SpriteEngine.Engine.Y:=SpriteEngine.Engine.Y+0.5;// Move a tela para Cima
  SpriteEngine.Move(ALagCount);// Move os Sprites
  SpriteEngine.Dead;//


  SpriteEngine2.Move(ALagCount);// Move e atualiza os Sprites
  SpriteEngine2.Dead;// Finaliza a atualização dos sprites



  TelaDX.Surface.Fill(0);//Limpa a Tela do DXDraw (TelaDX)
  SpriteEngine.Draw; // Desenha Todas as naves
  SpriteEngine2.Draw; // Desenha o fundo da tela

   // Desenha a energia da nave do jogador
   With TelaDx.Surface.Canvas do
   begin
   Brush.Style := bsClear;
   Font.Color := clWhite;
   Font.Size := 12;
   pen.Color:=ClBlue;
   pen.Width:=15;
   TextOut(10,10,'Energia: '+ IntToStr(Energia_Jogador));
   TextOut(10,30,'Engine Scrool: '+ formatFloat('000.###' ,SpriteEngine.Engine.Y));
   Release;
   end;


end;

{========================================================}


procedure TFormTroll.TelaApresentacao;

Const msg='Aperte Start';
var
  Logo: TPictureCollectionItem;
begin

  {  Title scene  }
  TelaDX.Surface.Fill(0);// Limpa a tela
  // Localiza a imagem com o nome do jogo e autor
  Logo := ImageList.Items.Find('Logo');
  // Desenha o logotipo na posição (0,0) sem alterações na imagem
  // Para alterar a imagem, colocando escalas e distorções  experimente
  // alteara os 4 últimos 0;
  //Logo.DrawWaveX(TelaDX.Surface, 120, 80, Logo.Width, Logo.Height, 0, 0, 0, 0);
  Logo.DrawWaveX(TelaDX.Surface, 0, 0, Logo.Width, Logo.Height, 0, 0, 0, 0);
  // Faz piscar a frase "Aperte Start"
  with TelaDX.Surface.Canvas do
   if SMsg then
  begin
    Brush.Style := bsClear;
    Font.Name:='Tahoma';
    Font.Color := clRed;
    Font.Size := 40;
    Font.Color := clWhite;
    Font.Size := 30;
    Textout(200, 300, msg);
    Release;
    end;
 // Se Apertou o botão Barra de espaço então
 // inicia o loop do jogo
 if isButton1 in DXInput.States then
    begin

       MP1.Stop;
       Mp1.Close;
       MP1.FileName:='Pride.wav';
       MP1.Open;
       Mp1.Play;
      DXInput.Update;
      SpriteEngine.Engine.Y:=0;
      Inicializa_Nave_Principal;
      Inicializa_Inimigo;
      Sleep(500);// Espera 0,5  segundos
      Cena:=Jogo;
      Dados.TimerEnemy.Enabled:=True;
    end;
end;

{====================================================}

procedure TFormTroll.LogoTimer(Sender: TObject);
begin
// Esta operação habilita ou desabilita a escrita
// da mensagem "Aperte Start" na tela de abertura
// do jogo

SMsg:= not SMsg;

end;

procedure TFormTroll._GameOver;
{var
  Logo: TPictureCollectionItem; }
begin
  dados.TimerEnemy.Enabled:=False;
  DXTimer1.Enabled:=False;
  TelaDX.Surface.Fill(0);// Limpa o DXDraw (TelaDx)

 { Logo := ImageList.Items.Find('GameOverTema');
  Logo.DrawWaveX(TelaDX.Surface, 0, 0, Logo.Width, Logo.Height, 0, 0, 0, 0); }

  with TelaDX.Surface.Canvas do
  begin
    Brush.Style := bsClear;
    Font.Color := clRed;
    Font.Size := 40;
    Textout(200, 200, 'Game Over');
    Release;

    end;

 Cena:=GameOver;
 TelaDx.Flip;
 Sleep(500);// Espera 0,5  segundos
// SpriteEngine.Engine.Clear;
// if Nave_Garra<>nil then Nave_Garra.Destroy;
// if Troll<>nil then Troll.Destroy;

// Logo.Enabled:= True;
// Cena:=Abertura;


end;
{===============================================}
procedure TFormTroll.Inicializa_Inimigo;
begin
 // Nave_Garra :=
//  TGarra.Create(SPriteEngine2.Engine);

end;

procedure TFormTroll.Inicializa_Nave_Principal;
begin
// Troll :=
 TPlayer.Create(SPriteEngine2.Engine);
  
end;

procedure TFormTroll.Mostra_Erro(Sender: TObject; E: Exception);
begin
  ShowMessage('Obrigado por jogar SpaceTroll!!!');
  Halt(0);
end;

procedure TFormTroll._Vitoria;
{var
  Logo: TPictureCollectionItem;}
begin
  dados.TimerEnemy.Enabled:=False;
  DXTimer1.Enabled:=False;
  SpriteEngine.Engine.Clear;
  TelaDX.Surface.Fill(0);// Limpa o DXDraw (TelaDx)
  DXInput.Update;
  Sleep(15);


  {Logo := ImageList.Items.Find('VitoriaTema');
  Logo.DrawWaveX(TelaDX.Surface, 0, 0, Logo.Width, Logo.Height, 0, 0, 0, 0); }


  with TelaDX.Surface.Canvas do
  begin
    Brush.Style := bsClear;
    Font.Color := clWhite;
    Font.Size := 30;
    Textout(170, 130, 'Congratulações');
    Font.Size := 20;
    Font.Color := clRed;
    Textout(25, 200, 'Você é ogrande defensor da Galaxia Vanquisher');
    Font.Color := clBlue;
    Textout(200, 280, 'Pontuação: '+ inttoStr(Pontos));
    Release;

    end;
    sndPlaySound(#0,0);
   // sndPlaySound('Vitoria.wav', SND_ASYNC );
    // ExecuteSoundWave(PChar(''));
    // ExecuteSoundWave(PChar('Vitoria'));
       MP1.Stop;
       Mp1.Close;
       MP1.FileName:='Vitoria.wav';
       MP1.OnNotify:=nil;
       MP1.Open;
       Mp1.Play;
 TelaDx.Flip;

  

 SpriteEngine2.Engine.Clear;



end;

procedure TFormTroll.TelaDXInitialize(Sender: TObject);
begin
DXTimer1.Enabled:=True;
end;

procedure TFormTroll.TelaDXFinalize(Sender: TObject);
begin
DXTimer1.Enabled:=False;
end;

procedure TFormTroll.MediaPlayerNotify(Sender: TObject);
begin
if TMediaplayer(Sender).Mode=mpStopped then
   begin
    TMediaplayer(Sender).Rewind;
    TMediaplayer(Sender).Play;
   end;
end;

procedure TFormTroll.FormActivate(Sender: TObject);
begin
Cena:=Abertura;
end;

end.
