{ *******************************************************************************
  Title: T2Ti ERP
  Description: Fun��es e procedimentos do SPED Fiscal;

  The MIT License

  Copyright: Copyright (C) 2010 T2Ti.COM

  Permission is hereby granted, free of charge, to any person
  obtaining a copy of this software and associated documentation
  files (the "Software"), to deal in the Software without
  restriction, including without limitation the rights to use,
  copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the
  Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
  OTHER DEALINGS IN THE SOFTWARE.

  The author may be contacted at:
  t2ti.com@gmail.com</p>

  @author Albert Eije (T2Ti.COM)
  @version 1.0
  ******************************************************************************* }

unit USpedFiscal;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ACBrEFDBlocos,
  Dbtables, Inifiles, Generics.Collections, ACBrSpedFiscal, ACBrUtil, ACBrTXTClass;

procedure GerarBloco0;
procedure GerarBlocoC;
procedure GerarArquivoSpedFiscal(DataIni:String;DataFim:String);

implementation

uses
UDataModule, EmpresaController, EmpresaVO, UnidadeController, UnidadeVO,
ContadorController, ContadorVO, ProdutoController, ProdutoVO, NF2Controller,
NF2CabecalhoVO, NF2DetalheVO, ImpressoraController, ImpressoraVO, R02VO, RegistroRController;

var
  Empresa : TEmpresaVO;

{ TODO : O que existe de incorreto neste procedimento? }
//Bloco 0
procedure GerarBloco0;
var
  EmpresaControl: TEmpresaController;
  ContadorControl: TContadorController;
  Contador: TContadorVO;
  UnidadeControl: TUnidadeController;
  ListaUnidade: TObjectList<TUnidadeVO>;
  ProdutoControl: TProdutoController;
  ListaProduto: TObjectList<TProdutoVO>;
  i:integer;
begin
  EmpresaControl := TEmpresaController.Create;
  Empresa := EmpresaControl.PegaEmpresa(StrToInt(FDataModule.IdEmpresa));
  ContadorControl := TContadorController.Create;
  Contador := ContadorControl.PegaContador;
  UnidadeControl := TUnidadeController.Create;
  ListaUnidade := UnidadeControl.TabelaUnidade;
  ProdutoControl := TProdutoController.Create;
  ListaProduto := ProdutoControl.TabelaProduto;

  with FDataModule.ACBrSpedFiscal.Bloco_0 do
  begin
    // Dados da Empresa
    with Registro0000New do
    begin
      { TODO : De onde pegar essa vers�o? }
      //C�digo da vers�o do leiaute conforme a tabela indicada no Ato Cotepe.
      COD_VER    := vlVersao102;
      { TODO : Como indicar a finalidade? Sempre ser� 0? }
      //0 - Remessa do arquivo original;
      //1 - Remessa do arquivo substituto.
      COD_FIN    := raOriginal;
      NOME       := Empresa.RazaoSocial;
      CNPJ       := Empresa.CNPJ;
      CPF        := ''; // Deve ser uma informa��o valida
      UF         := Empresa.UF;
      IE         := Empresa.InscricaoEstadual;
      COD_MUN    := Empresa.CodigoMunicipioIBGE;
      IM         := Empresa.InscricaoMunicipal;
      { TODO : � importante ter essa informa��o na tabela Empresa? }
      SUFRAMA    := '';
      { TODO : Devemos armazear essa informa��o no Banco? }
      //A � Perfil A;
      //B � Perfil B;
      IND_PERFIL := pfPerfilA;
      //0 � Industrial ou equiparado a industrial;
      //1 � Outros.
      IND_ATIV   := atOutros;
    end;
    with Registro0001New do
    begin
      //Indicador de movimento:
      IND_MOV := imComDados;
      // FILHO - Dados complementares da Empresa
      with Registro0005New do
      begin
        FANTASIA   := Empresa.NomeFantasia;
        CEP        := Empresa.CEP;
        ENDERECO   := Empresa.Endereco;
        NUM        := '';
        COMPL      := Empresa.Complemento;
        BAIRRO     := Empresa.Bairro;
        FONE       := Empresa.Fone1;
        FAX        := Empresa.Fone2;
        { TODO : Informa��o importante? }
        EMAIL      := '';
      end;
      // FILHO - Dados do contador.
      with Registro0100New do
      begin
        NOME       := Contador.Nome;
        CPF        := Contador.CPF;
        CRC        := Contador.CRC;
        CNPJ       := Contador.CNPJ;
        CEP        := Contador.CEP;
        ENDERECO   := Contador.Logradouro;
        NUM        := IntToStr(Contador.Numero);
        COMPL      := Contador.Complemento;
        BAIRRO     := Contador.Bairro;
        FONE       := Contador.Fone;
        FAX        := Contador.Fax;
        EMAIL      := Contador.Email;
        COD_MUN    := Contador.CodigoMunicipio;
      end;
      // FILHO - Identifica��o das unidades de medida
      for i := 0 to ListaUnidade.Count - 1 do
      begin
        with Registro0190New do
        begin
            UNID := TUnidadeVO(ListaUnidade.Items[i]).Nome;
            DESCR := TUnidadeVO(ListaUnidade.Items[i]).Descricao;
        end;
      end;

      // FILHO - Tabela de Identifica��o do Item (Produtos e Servi�os)
      for i := 0 to ListaProduto.Count - 1 do
      begin
        with Registro0200New do
        begin
          { TODO : Informamos o que aqui? O ID mesmo? }
          COD_ITEM := IntToStr(TProdutoVO(ListaProduto.Items[i]).Id);
          DESCR_ITEM := TProdutoVO(ListaProduto.Items[i]).Nome;
          COD_BARRA := TProdutoVO(ListaProduto.Items[i]).GTIN;
          { TODO : O que informar aqui? }
          COD_ANT_ITEM := TProdutoVO(ListaProduto.Items[i]).UnidadeProduto;
          UNID_INV := TProdutoVO(ListaProduto.Items[i]).UnidadeProduto;
          { TODO : De onde vamos pegar essa informa��o? }
          TIPO_ITEM :=  tiProdutoAcabado;
          COD_NCM := TProdutoVO(ListaProduto.Items[i]).NCM;
          EX_IPI := '';
          { TODO : O que informar aqui? }
          COD_GEN := '';
          { TODO : O que informar aqui? }
          COD_LST := '';
          ALIQ_ICMS := TProdutoVO(ListaProduto.Items[i]).AliquotaICMS;
        end;
      end;
    end;
  end;
end;

procedure GerarBlocoC;
var
  NF2Control: TNF2Controller;
  ImpressoraControl: TImpressoraController;
  ListaImpressora: TObjectList<TImpressoraVO>;
  ListaNF2Cabecalho: TObjectList<TNF2CabecalhoVO>;
  ListaNF2Detalhe: TObjectList<TNF2DetalheVO>;
  RegistroRControl : TRegistroRController;
  ListaR02: TObjectList<TR02VO>;
  i,j:integer;
begin
  with FDataModule.ACBrSpedFiscal.Bloco_C do
  begin
    with RegistroC001New do
    begin
      IND_MOV := imComDados;
      //
      NF2Control := TNF2Controller.Create;
      ListaNF2Cabecalho := NF2Control.TabelaNF2Cabecalho;
      for i := 0 to ListaNF2Cabecalho.Count - 1 do
      begin
        with RegistroC350New do
        begin
          SER := TNF2CabecalhoVO(ListaNF2Cabecalho.Items[i]).Serie;
          SUB_SER := TNF2CabecalhoVO(ListaNF2Cabecalho.Items[i]).SubSerie;
          NUM_DOC := TNF2CabecalhoVO(ListaNF2Cabecalho.Items[i]).Numero;
          DT_DOC := StrToDateTime(TNF2CabecalhoVO(ListaNF2Cabecalho.Items[i]).DataHoraEmissao);
          { TODO : Como pegar essa informa��o? }
          CNPJ_CPF := '';
          VL_MERC := TNF2CabecalhoVO(ListaNF2Cabecalho.Items[i]).TotalProdutos;
          VL_DOC := TNF2CabecalhoVO(ListaNF2Cabecalho.Items[i]).TotalNF;
          VL_DESC := TNF2CabecalhoVO(ListaNF2Cabecalho.Items[i]).Desconto;
          VL_PIS := TNF2CabecalhoVO(ListaNF2Cabecalho.Items[i]).PIS;
          VL_COFINS := TNF2CabecalhoVO(ListaNF2Cabecalho.Items[i]).COFINS;
          { TODO : O que devemos informar nessa op��o? }
          COD_CTA := '';

          //C370
          ListaNF2Detalhe := NF2Control.TabelaNF2Detalhe(TNF2CabecalhoVO(ListaNF2Cabecalho.Items[i]).Id);
          if Assigned(ListaNF2Detalhe) then
          begin
            for j := 0 to ListaNF2Detalhe.Count - 1 do
            begin
              with RegistroC370New do   //Inicio Adicionar os Itens:
              begin
                NUM_ITEM := IntToStr(TNF2DetalheVO(ListaNF2Detalhe.Items[j]).Item);
                { TODO : Podemos/devemos manter o ID do produto aqui? }
                COD_ITEM := IntToStr(TNF2DetalheVO(ListaNF2Detalhe.Items[j]).IdProduto);// C�digo do Item (campo 02 do registro 0200)
                QTD := TNF2DetalheVO(ListaNF2Detalhe.Items[j]).Quantidade;
                { TODO : Como pegar esse dado? }
                UNID := '';
                VL_ITEM := TNF2DetalheVO(ListaNF2Detalhe.Items[j]).ValorTotal;
                VL_DESC := TNF2DetalheVO(ListaNF2Detalhe.Items[j]).Desconto;
              end; //Fim dos Itens;
            end;//fim do for dos itens
          end;//fim do teste se voltou lista de itens
        end;//fim do registro 350
      end;//fim do la�o na lista cabecalho

      ImpressoraControl := TImpressoraController.Create;
      ListaImpressora := ImpressoraControl.TabelaImpressora;
      for i := 0 to ListaImpressora.Count - 1 do
      begin
        with RegistroC400New do
        begin
          { TODO : Onde vamos armazenar esse c�digo para futura recupera��o? }
          COD_MOD := 'D2';
          ECF_MOD := TImpressoraVO(ListaImpressora.Items[i]).Modelo;
          ECF_FAB := TImpressoraVO(ListaImpressora.Items[i]).Serie;
          { TODO : Informamos o ID mesmo aqui? }
          ECF_CX := IntToStr(TImpressoraVO(ListaImpressora.Items[i]).Id);

          //C405
          ListaR02 := RegistroRControl.TabelaR02Id(TImpressoraVO(ListaImpressora.Items[i]).Id);
          if Assigned(ListaR02) then
          begin
            for j := 0 to ListaR02.Count - 1 do
            begin
              with RegistroC405New do   //Inicio Adicionar os Itens:
              begin
                DT_DOC := StrToDateTime(TR02VO(ListaR02.Items[j]).DataMovimento);
                CRO := TR02VO(ListaR02.Items[j]).CRO;
                CRZ := TR02VO(ListaR02.Items[j]).CRZ;
                NUM_COO_FIN := TR02VO(ListaR02.Items[j]).COO;
                GT_FIN := TR02VO(ListaR02.Items[j]).GrandeTotal;
                VL_BRT := TR02VO(ListaR02.Items[j]).VendaBruta;
              end; //Fim dos Itens;
            end;//fim do for dos itens
          end;//fim do teste se voltou lista de itens
        end;//fim do registro 400
      end;//fim do la�o na lista cabecalho

    end;//fim do registro C0001
  end;//fim do bloco C
end;

procedure GerarArquivoSpedFiscal(DataIni:String;DataFim:String);
begin
  with FDataModule.ACBrSpedFiscal do
  begin
     DT_INI := StrToDate(DataIni);
     DT_FIN := StrToDate(DataFim);
  end;

  GerarBloco0;
  GerarBlocoC;
  FDataModule.ACBrSpedFiscal.SaveFileTXT ;
end;

end.

