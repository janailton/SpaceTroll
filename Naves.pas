unit Naves;

interface
 uses SysUtils,DirectX,ActiveX,DXClass, DXDraws, DXInput, DXSprite,MMSystem,
 ExtCtrls,Forms;



  Type
   // O tiro sobe ou desce?
   TSentido=(Sobe,Desce,Esquerda,Direita);


 {++++++++++++++++++++++++++++++++++++}

  // Eis a sua nave jogador !!
 TPlayer=Class(TImageSprite)
  Public
    Energia : integer; // sem comentários
    DanosCont: Integer;// quantos segundos a nave piscará?
    ShootTime: Integer;// quanto tempo esperar para atirar entre cada intervalo de tiro
    Constructor Create(AParent: TSprite);override;
  protected
    Procedure Atira;// Pode atirar?
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;// verifica colisões
    procedure DoMove(MoveCount: Integer); override;// movimenta a nave;
  Private
    Shoot_Timer: TTimer;
    Visibilidade_Timer: TTimer;
    Procedure TimerShoot(Sender:TObject);
    Procedure TimerVisibilidade(Sender:TObject);

 end;


 {++++++++++++++++++++++++++++++++++++++++++++++}
 // Eu criei todos as naves importantes do jogo tendo
 // por base TInimigo isso para evitar implementar um
 // construtor e destrutor para cada nave.
 // Esse objeto é bem simples como você vai observar.
 TInimigo=Class(TImageSprite)
  Public
    Energia : integer;
    Constructor Create(AParent: TSprite);override;
    Destructor Destroy; override;
  protected
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure DoMove(MoveCount: Integer); override;
    Procedure Inicializa;Virtual;Abstract;
  end;

{++++++++++++++++++++++++++++++++++++++++++++++++++}

  TGarra=Class(TInimigo)
   Protected
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure DoMove(MoveCount: Integer); override;
    Procedure Inicializa;Override;
   end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++}

TAlien_Ovo=Class(TInimigo)
   Protected
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
     procedure DoMove(MoveCount: Integer); override;
    Procedure Inicializa;Override;
   end;


 {=============================================================}

 TAlien_Espinho=Class(TAlien_Ovo)
   Protected
    procedure DoMove(MoveCount: Integer); override;
    Procedure Inicializa;Override;
  Private
  Sentido: TSentido;
  end;

{===============================================================}




  TBlindado=Class(TAlien_Espinho)
   Private
   
   Protected
    procedure DoMove(MoveCount: Integer); override;
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    Procedure Inicializa;Override;
   end;




{++++++++++++++++++++++++++++++++++++++++++++++}


// Aqui são criados os objetos responsáveis pelas explosões

  TExplode=record
     X,
     Y,
     Tempo: integer;
     Ativo: Boolean;
    end;

  TExplosao=Class(TImageSprite)
    Private
      CanDestroY: Boolean;
      Tempo: integer;// Tempo para altenar a imagem da explosão
      Timer: TTimer; // Controla o tempo para altenar a imagem da explosão
      Procedure DecTimer(Sender:TObject);//Loop que lterna as imagens da explosão
    Public
      Constructor Create(AParent: TSprite);override;// inicializa objetos
      Destructor Destroy;override;// Finaliza objetos
   end;

   





{==================================================================}



  TTiro=Class(TImageSprite)
  Public
    Sentido: TSentido;
    Atirou: Boolean;
  protected
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure DoMove(MoveCount: Integer); override;
    Destructor Destroy;Override;
 end;



{================================================================}





{------------------------------------------------------------------}

  TPonto=Record
      X,
      Y: Double;
    end;
 

   Garra_List=record
       Nav_Garra: array[1..20] of TGarra;
       Indice: integer;
      end;


 
{----------------------------------------------}
    // Variáveis de controle local

 Var
  TrollPonto: TPonto; // Esta é sua nave, jogador!!!
  Nave_Garra:  Garra_List;// Um inimigo
  Tiro: TTiro;// sem comentários
 // Pt1:PTTiro; //...
  Tiros:array[1..10] of TTiro;
  Energia_Jogador: integer;// Mostra a energia do jogador no TextOut do DXDraw (TelaDX)
 // PExplosao:PTExplosao;
  Pontos: integer=0;
  TMap: TImageSprite;
 Procedure Insere_inimigo_Garra;
 

implementation

uses Main, DModule;

{===================================================}

Procedure CriaTiro(Xa,Ya: Double; ASentido: TSentido);
 //var
 // PTiro:^TTiro;
 begin
 // New(P);
 // P^ := TTiro.Create(FormTroll.SPriteEngine.Engine);
//  with TTiro(P^) do
   with (TTiro.Create(FormTroll.SPriteEngine2.Engine)) do
  begin
    sndPlaySound('Laser.wav', SND_ASYNC );
    Image := FormTroll.ImageList.Items.Find('bigplasma');
    Collisioned:=true;
    pixelcheck:=false;
    Z := 0;
    Width := Image.Width;
    Height := Image.Height;
    x:=Xa;
    Sentido:= ASentido;
    if Sentido=sobe then
      y:=Ya-40
        else
         if Sentido=Desce then
      y:=Ya+40;

    visible:=true;
    Atirou:=True;
    Collisioned:=True;

   end;

 end;


 {=====================================================}


 // Coloque aqui as Naves que serão inseridas no jogo
  Procedure Insere_inimigo_Garra;
   begin

    if Application.Terminated then Exit;
     if Nave_Garra.Indice>19 then
        begin
          if (FormTroll.Cena=jogo)  then FormTroll.Cena:=Vitoria;
          Exit;
        end;
     Nave_Garra.Nav_Garra[Nave_Garra.Indice]:=TGarra.Create(FormTroll.SPriteEngine2.Engine);
     inc(Nave_Garra.Indice);
     // TGarra.Create(FormTroll.SPriteEngine.Engine);
  end;


{=====================================================}

{ TPlayer }
procedure TPlayer.Atira;
begin
{if Tiro<> nil then
  if Tiro.Atirou then Exit;}

  Shoot_Timer.Enabled:=True;
  ShootTime:=2;
  Tiro := TTiro.Create(FormTroll.SPriteEngine2.Engine);
  with TTiro(Tiro) do
   begin
    sndPlaySound('Laser.wav', SND_ASYNC );
    Image := FormTroll.ImageList.Items.Find('plasma');
    Collisioned:=true;
    pixelcheck:=false;
    Z := 0;
    Width := Image.Width;
    Height := Image.Height;
    x:=(TrollPonto.X-10) ;
    y:=TrollPonto.Y-50;
    visible:=true;
    Atirou:=True;
    Tiro.Collisioned:=True;
  end;
 with (TTiro.Create(FormTroll.SPriteEngine2.Engine)) do
   begin
    sndPlaySound('Laser.wav', SND_ASYNC );
    Image := FormTroll.ImageList.Items.Find('plasma');
    Collisioned:=true;
    pixelcheck:=false;
    Z := 0;
    Width := Image.Width;
    Height := Image.Height;
    x:=(TrollPonto.X+30);
    y:=TrollPonto.Y-50;
    visible:=true;
    Atirou:=True;
    Tiro.Collisioned:=True;
  end;

end;



{...................................................}



constructor TPlayer.Create(AParent: TSprite);
begin
  inherited Create(AParent);
    Image := FormTroll.ImageList.Items.Find('ntroll');
    Collisioned:=true; // Mapeia as colisões
    pixelcheck:=false;
    Z := 0;
    Width := Image.Width;
    Height := Image.Height;
    x:=300;
    y:=FormTroll.SpriteEngine2.Engine.Y+300;
    Energia:=400;
    Energia_Jogador:=Energia;
    visible:=true;
    ShootTime:=0;

  Shoot_Timer:=TTimer.Create(nil);
  Shoot_Timer.OnTimer:=TimerShoot;
  Shoot_Timer.Interval:=150;
  Shoot_Timer.Enabled:=True;

  Visibilidade_Timer:=TTimer.Create(nil);
  Visibilidade_Timer.OnTimer:=TimerVisibilidade;
  Visibilidade_Timer.Interval:=80;
  Shoot_Timer.Enabled:=False;

end;

procedure TPlayer.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  inherited DoCollision(Sprite, Done);
   // Eu coloquei todas as perdas de energia da nave do jogador aqui,
   // exceto as colisoões dos tiros para
   // não ter que descobrir em outro evento quem causou a colisão, visto
   // que a nave do jogador é criada dinamicamente, assim como as outras
   // naves.
 //  if (Sprite is TTiro ) then
  //    begin
      //  if  (TTiro(Sprite).Sentido=Desce) then
      //      Energia:=Energia-30
      //      else Collisioned := True;
  //    end;


  if (Sprite is TGarra) then
  begin
    sndPlaySound('Pow.wav', SND_ASYNC );
    Energia:= Energia-50;
    Collisioned := False;
    DanosCont:=20;

   { Image := FormTroll.ImageList.Items.Find('nletal');
    Width := Image.Width;
    Height := Image.Height; }
  end;

  if (Sprite is TAlien_Ovo) then
  begin
    sndPlaySound('Pow.wav', SND_ASYNC );
    Energia:= Energia-75;
    Collisioned := False;
    DanosCont:=20;
    TAlien_Ovo(Sprite).Dead; 
  end;


   if (Sprite is TAlien_Espinho) then
  begin
    sndPlaySound('Pow.wav', SND_ASYNC );
    Energia:= Energia-75;
    Collisioned := False;
    DanosCont:=20;
    TAlien_Espinho(Sprite).Dead; 
  end;


 Energia_Jogador:=Energia;
 Visibilidade_Timer.Enabled:=True;
 Visible:=False;

end;


{...................................................}

procedure TPlayer.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
   if (isDown in FormTroll.DXInput.States) and (Y <(engine.Height-Engine.Y)-70) then
    Self.Y:=Y+2;//MoveCount/5;
   if (isUP in FormTroll.DXInput.States) and (Y > (engine.Height-Engine.Y)-450) then
    Self.Y:=Y-2;//MoveCount/5;
 // y:=Y-0.2;
   if (isLeft in FormTroll.DXInput.States)and (X >0) then
    Self.X:=X-2;//MoveCount/5;
   if (isRight in FormTroll.DXInput.States) and (X <formTroll.TelaDX.Width- 40) then
    Self.X:=X+2;//MoveCount/5;
   if (isButton1 in FormTroll.DXInput.States) then if ShootTime<=0 then Atira;

  if (Y >(engine.Height-Engine.Y)-30) then Y:=((engine.Height-Engine.Y)-30);

   TrollPonto.X:=X;
   TrollPonto.Y:=Y;
   Collision; // Sempre chame as colisões nesta rotina

   // Engine.Y:=Engine.Y+0.5;// Move a tela para Cima

   // Verifique se o jogador está sem energia nesta rotina
   if Energia<=0 then
   begin

     FormTroll.Cena:=GameOver;
   end;



end;


{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}


{ TIimigo }
constructor TInimigo.Create(AParent: TSprite);
begin
 inherited Create(AParent);
 Inicializa;
end;

{===============================================================}

destructor TInimigo.Destroy;
begin

With (TExplosao.Create(FormTroll.SpriteEngine2.Engine)) do
      begin
        Collisioned := False;
        X:=Self.X;
        Y:=Self.Y;
        Z:=3;
       end;

With (TExplosao.Create(FormTroll.SpriteEngine2.Engine)) do
      begin
        Collisioned := False;
        X:=Self.X+10;
        Y:=Self.Y;
        Z:=3;
       end;

With (TExplosao.Create(FormTroll.SpriteEngine2.Engine)) do
      begin
        Collisioned := False;
        X:=Self.X+20;
        Y:=Self.Y;
        Z:=3;
       end;

With (TExplosao.Create(FormTroll.SpriteEngine2.Engine)) do
      begin
        Collisioned := False;
        X:=Self.X;
        Y:=Self.Y+10;
        Z:=3;
       end;

With (TExplosao.Create(FormTroll.SpriteEngine2.Engine)) do
      begin
        Collisioned := False;
        X:=Self.X+10;
        Y:=Self.Y+10;
        Z:=3;
       end;

With (TExplosao.Create(FormTroll.SpriteEngine2.Engine)) do
      begin
        Collisioned := False;
        X:=Self.X+20;
        Y:=Self.Y+10;
        Z:=3;
       end;

With (TExplosao.Create(FormTroll.SpriteEngine2.Engine)) do
      begin
        Collisioned := False;
        X:=Self.X;
        Y:=Self.Y+30;
        Z:=3;
       end;

With (TExplosao.Create(FormTroll.SpriteEngine2.Engine)) do
      begin
        Collisioned := False;
        X:=Self.X+10;
        Y:=Self.Y+30;
        Z:=3;
       end;

With (TExplosao.Create(FormTroll.SpriteEngine2.Engine)) do
      begin
        Collisioned := False;
        X:=Self.X+20;
        Y:=Self.Y+30;
        Z:=3;
       end;

inherited destroy;
end;

{===================================================================}




procedure TInimigo.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  inherited DoCollision(Sprite, Done);

// esta rotina verifica se as naves inimigas colidiram
// caso colidam elas são reorganizadas  
if (Sprite is TInimigo) then
  begin
   if Sprite.X< Self.X then
    begin
      Self.X:= Self.X+1;
      Sprite.X:=Sprite.X-1;
    end
     else
       begin
         Self.X:= Self.X-1;
         Sprite.X:=Sprite.X+1;
       end;
  end;


end;

{.........................................................}


procedure TInimigo.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
 
end;


{+++++++++++++++++++++++++++++++++++++++++++++++++++++++}





procedure TPlayer.TimerShoot(Sender: TObject);
begin
  if (ShootTime >=0) then
     Dec(ShootTime)
    
end;

procedure TPlayer.TimerVisibilidade(Sender: TObject);
begin

   if DanosCont>0 then;
        Dec(DanosCont,2);
  if (Collisioned=True) then //se colidiu faz piscar a nave
    begin
      Visible:=True;
      Visibilidade_Timer.Enabled:=False;
      Exit;
   end
  else
  begin
     if DanosCont<1 then
      begin
         Collisioned:=True;
         DanosCont:=20;

      end;

     Visible:= not Visible;
  end;
end;

{ TTiro }
destructor TTiro.Destroy;
begin

  inherited Destroy;;
end;

procedure TTiro.DoCollision(Sprite: TSprite; var Done: Boolean);
 var
 Xaux,Yaux: Double;
begin
  inherited DoCollision(Sprite, Done);

 if (Sprite is TPlayer) then
      with TPlayer(Sprite) do
        begin
          Energia:= Energia-30;
          Energia_Jogador:=Energia;
        end;

 if (Sprite is TInimigo) then
      with TInimigo(Sprite) do
        Begin
         Energia:= Energia-72;

        end;

  Xaux:=X; Yaux:=Y;// Coordenadas que servem para posicionar as explosões

  // Nesta rotina é criado um objeto do tipo TExplosao
  // que mudará sua imagem "por conta própria" na sua rotina DecTimer
  if (Sprite is TInimigo)or (Sprite is TPlayer) then
  With (TExplosao.Create(FormTroll.SpriteEngine2.Engine)) do
      begin
        Collisioned := False;
        X:=Xaux;
        Y:=Yaux;
        Z:=3;
       end;



  Atirou:=False;
  Dead;
end;

{.....................................................}


procedure TTiro.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  Case Sentido of
    Sobe: Y:=Y-5;
    Desce: Y:=Y+5;
    end;
  {if Sentido= Sobe then
          y:=Y-2;
  if Sentido= Desce then
          y:=Y+2;}
  if Y<0 then Atirou:= false;
  Collision;

 
end;
{++++++++++++++++++++++++++++++++++++++++++++++}






{ TExplosao }

constructor TExplosao.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  Tempo:=6;
  CanDestroY:= False;
  Image := FormTroll.ImageList.Items.Find('Explode1');
  Collisioned:=False;
  pixelcheck:=false;
  Z := 0;
  Width := Image.Width;
  Height := Image.Height;
  visible:=true;
  Timer:=TTimer.Create(nil);
  Timer.OnTimer:=DecTimer;
  Timer.Interval:=30;
  Timer.Enabled:=True;
end;

procedure TExplosao.DecTimer(Sender: TObject);
begin
  Dec(Tempo);
  case Tempo of
      6: Image:=FormTroll.ImageList.Items.Find('Explode1');
      5: Image:=FormTroll.ImageList.Items.Find('Explode2');
      4: Image:=FormTroll.ImageList.Items.Find('Explode3');
      3: Image:=FormTroll.ImageList.Items.Find('Explode4');
      2: Image:=FormTroll.ImageList.Items.Find('Explode5');
      1: Image:=FormTroll.ImageList.Items.Find('Explode6');
    end;
  if Tempo<1 then
   begin
     Timer.Enabled:=False;
     Timer.OnTimer:=nil;
     Dead;
   // Image:=FormTroll.ImageList.Items.Find('Nada');
    //Timer.Enabled:=False;
    //Timer.OnTimer:=nil;
    // Destroy; //CanDestroY:=True;
   end;
end;

destructor TExplosao.Destroy;
begin
  Timer.Free;
 inherited Destroy; 
end;


{ TTgarra }

procedure TGarra.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  inherited DoCollision(Sprite, Done);
  // Finaliza TGarra
  // com isto o FormTroll.SpriteEngine irá destruir TGarra

end;



procedure TGarra.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  if (Y> 490) then //se está abaixo da tela
    Dead;// Finaliza a nave

  y:=Y+2;
 // x:=X+cos(10);
  if x= TrollPonto.X  then exit;
  if x< TrollPonto.X then x:=x+1;
  if x>TrollPonto.X  then X:=X-1;
  if Random(35)=4 then
    CriaTiro(X,Y+Image.Width,Desce);
  if Visible=False then Visible:=True;

  Collision;

   if Self.Energia<=0 then
      begin
       pontos:=pontos+175;
       Dead;
      end;
 end;
procedure TGarra.Inicializa;
begin

  Image := FormTroll.ImageList.Items.Find('ngarra');
  Collisioned:=true;
  pixelcheck:=false;
  Z := 0;
  Width := Image.Width;
  Height := Image.Height;
  x:=random(430);
 // y:= (engine.Height-Engine.Y)-450;
  Energia:=150;
  visible:=true;

end;

{ TAlien_Ovo }

procedure TAlien_Ovo.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  inherited DoCollision(Sprite, Done);;
  
 
end;

procedure TAlien_Ovo.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  Y:=Y+1;
  Collision;
  if Energia <0 then Dead;

end;

procedure TAlien_Ovo.Inicializa;
begin
  Image := FormTroll.ImageList.Items.Find('AlienOvo');
  Collisioned:=true;
  pixelcheck:=false;
  Z := 0;
  X:= TrollPonto.X;
  Width := Image.Width;
  Height := Image.Height;
  Self.Energia:=75;
  Self.Visible:=True;

end;

{ TAlien_Espinho }

procedure TAlien_Espinho.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  Y:=Y+1;
  Case Sentido of
     Esquerda: X:=X-0.5;
     Direita: X:=X+0.5;
  end;
end;
procedure TAlien_Espinho.Inicializa;
begin
 Image := FormTroll.ImageList.Items.Find('AlienEspinho');
  Collisioned:=true;
  pixelcheck:=false;
  Z := 0;
  X:= random(450);
  If (TRollPonto.X< X) then Sentido:=Esquerda
    else Sentido:=Direita;
  Width := Image.Width;
  Height := Image.Height;
  Self.Energia:=75;
  Self.Visible:=True;


end;

{ TBlindado }

procedure TBlindado.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  inherited DoCollision(Sprite, Done);

end;



procedure TBlindado.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
   if (Random(35)=4)   and  (Y < TrollPonto.Y)
     then  CriaTiro(X,Y+Image.Width,Desce);
end;

procedure TBlindado.Inicializa;
begin
 Image := FormTroll.ImageList2.Items.Find('nBlindada');
  Collisioned:=true;
  pixelcheck:=false;
  Z := 0;
  Width := Image.Width;
  Height := Image.Height;
  x:=random(430);
  Energia:=150;
  visible:=true;
  // Estes métodos são herdados de TAlienn_Espinho
  If (TRollPonto.X< X) then Sentido:=Esquerda
    else Sentido:=Direita;

end;

end.
