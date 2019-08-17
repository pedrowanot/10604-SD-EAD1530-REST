unit UFrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtDocumentoCliente: TLabeledEdit;
    cmbTamanhoPizza: TComboBox;
    cmbSaborPizza: TComboBox;
    Button1: TButton;
    mmRetornoWebService: TMemo;
    edtEnderecoBackend: TLabeledEdit;
    edtPortaBackend: TLabeledEdit;
    btn_consultarpedido: TButton;
    procedure Button1Click(Sender: TObject);
    procedure btn_consultarpedidoClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

uses
  Rest.JSON, MVCFramework.RESTClient, UEfetuarPedidoDTOImpl, System.Rtti,
  UPizzaSaborEnum, UPizzaTamanhoEnum, UPedidoRetornoDTOImpl;

{$R *.dfm}

procedure TForm1.btn_consultarpedidoClick(Sender: TObject);
var
  Clt: TRestClient;
  oPedidoDTO: TPedidoRetornoDTO;
begin
  Clt := MVCFramework.RESTClient.TRestClient.Create(edtEnderecoBackend.Text, StrToIntDef(edtPortaBackend.Text, 80), nil);
  try
    oPedidoDTO:= TJson.JsonToObject<TPedidoRetornoDTO>(Clt.doGET('/consultarPedido', [edtDocumentoCliente.Text],nil).BodyAsString);
    try
      mmRetornoWebService.Clear;
      mmRetornoWebService.Lines.Add('###########');
      mmRetornoWebService.Lines.Add('Pedido nrº: '+edtDocumentoCliente.Text + '  ');
      mmRetornoWebService.Lines.Add('| Pizza | - Tamanho: '+getnomePizzaTamanhoEnum(oPedidoDTO.PizzaTamanho)+'. - Sabor: '+getnomePizzaSaborEnum(oPedidoDTO.PizzaSabor)+'.');
      mmRetornoWebService.Lines.Add(' - Valor Total: '+ FormatCurr('R$ 0.00',oPedidoDTO.ValorTotalPedido));
      mmRetornoWebService.Lines.Add(' - Tempo para preparar: '+ oPedidoDTO.TempoPreparo.ToString + ' minutos.');
      mmRetornoWebService.Lines.Add('###########');
    finally
      oPedidoDTO.Free;
    end;
  finally
    Clt.Free;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Clt: TRestClient;
  oEfetuarPedido: TEfetuarPedidoDTO;
begin
  Clt := MVCFramework.RESTClient.TRestClient.Create(edtEnderecoBackend.Text,
    StrToIntDef(edtPortaBackend.Text, 80), nil);
  try
    oEfetuarPedido := TEfetuarPedidoDTO.Create;
    try
      oEfetuarPedido.PizzaTamanho :=
        TRttiEnumerationType.GetValue<TPizzaTamanhoEnum>(cmbTamanhoPizza.Text);
      oEfetuarPedido.PizzaSabor :=
        TRttiEnumerationType.GetValue<TPizzaSaborEnum>(cmbSaborPizza.Text);
      oEfetuarPedido.DocumentoCliente := edtDocumentoCliente.Text;
      mmRetornoWebService.Text := Clt.doPOST('/efetuarPedido', [],
        TJson.ObjecttoJsonString(oEfetuarPedido)).BodyAsString;
    finally
      oEfetuarPedido.Free;
    end;
  finally
    Clt.Free;
  end;
end;

end.
