unit unit_xml_episode;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, Forms, Dialogs;

type
  TTestCaseXmlEpisode = class(TTestCase)
  published

    procedure cDataHtmlText();
    procedure htmlEntities();
    procedure fileNames();
    procedure urlsLocals();
    procedure byteLengths();
    procedure theEnclosure();
    procedure theEntities();
    procedure episodeCreations();
  end;

implementation

uses
  xml_episode,
  consts_types;

procedure TTestCaseXmlEpisode.cDataHtmlText();
var
  cdata_html_desc, text_desc: string;
begin
  cdata_html_desc := '<Description color=blue><![CDATA[' + '&lt;br&gt;' + 'real -' + LINE_ENDING +
    '<i>description</i>]]></Description>';
  text_desc := removeCDataHtmlElem(cdata_html_desc);
  assertEquals('no html in description', 'real - description', text_desc);
end;


procedure TTestCaseXmlEpisode.htmlEntities();
var
  html_entities_desc, text_desc: string;
begin
  html_entities_desc := '<item><title>title</title><description color=blue><![CDATA[' + '&lt;br&gt;' +
    'real -' + LINE_ENDING + '<i>description</i>&quot;]]></description></item>';
  text_desc := getTheDesc(html_entities_desc);
  assertEquals('no html in description', 'real - description"', text_desc);
end;


procedure TTestCaseXmlEpisode.fileNames();
var
  url_enclosure, url_filename, local_enclosure, local_filename: string;
begin
  url_enclosure := '<enclosure url="http://traffic.libsyn.com/joeroganexp/p1422.mp3?dest-id=19997" />';
  url_filename := filenameOfEpisode(url_enclosure);
  assertEquals('ignore html gets', 'p1422.mp3', url_filename);

  local_enclosure := '<enclosure url="/localfile/z1234.mp4" />';
  local_filename := filenameOfEpisode(local_enclosure);
  assertEquals('ignore html gets', 'z1234.mp4', local_filename);
end;


procedure TTestCaseXmlEpisode.urlsLocals();
var
  url_enclosure, url_filename, local_enclosure, local_filename: string;
begin
  url_enclosure := '<enclosure url="http://traffic.libsyn.com/joeroganexp/p1533.mp3?dest-id=19997" />';
  url_filename := urlOfEpisode(url_enclosure);
  assertEquals('ignore html gets', 'http://traffic.libsyn.com/joeroganexp/p1533.mp3', url_filename);

  local_enclosure := '<enclosure url="/localfile/abcde.mp4" />';
  local_filename := urlOfEpisode(local_enclosure);
  assertEquals('ignore html gets', '/localfile/abcde.mp4', local_filename);
end;


procedure TTestCaseXmlEpisode.byteLengths();
var
  url_enclosure, local_enclosure: string;
  has_bytes, no_bytes: integer;
begin
  url_enclosure := '<enclosure length="170337414" />';
  has_bytes := bytesOfEpisode(url_enclosure);
  assertEquals('ignore html gets', 170337414, has_bytes);

  local_enclosure := '<enclosure  />';
  no_bytes := bytesOfEpisode(local_enclosure);
  assertEquals('ignore html gets', 0, no_bytes);
end;


procedure TTestCaseXmlEpisode.theEnclosure();
var
  full_enclosure, odd_enclosure: string;
  enclosure_full, enclosure_odd: string;
begin
  full_enclosure := '<item><enclosure length="123" /></item>';
  enclosure_full := enclosureOfEpisode(full_enclosure);
  assertEquals('ignore html gets', ' length="123" /', enclosure_full);

  odd_enclosure := '<item><enclosure length="789">some text</enclosure></item>';
  enclosure_odd := enclosureOfEpisode(odd_enclosure);
  assertEquals('ignore html gets', ' length="789"', enclosure_odd);
end;


procedure TTestCaseXmlEpisode.theEntities();
var
  html_entities, clean_text: string;
begin
  html_entities := '&lt;&nbsp;&#60;&#160;&gt;&#62;&amp;&#38;&quot;&#34;&#8220;&#8221;&apos;&#39;&#8217;&cent;&#162;&pound;&#163;&yen;&#165;&euro;&#8364;&copy;&#169;&reg;&#174;';
  clean_text := htmlCharEntities(html_entities);
  assertEquals('ignore html gets', '< < >>&&""""''''''¢¢££¥¥€€©©®®', clean_text);
end;




procedure TTestCaseXmlEpisode.episodeCreations;
var
  url_and_filename: TUrlAndFilename;
  episode_text, ItemUrl, ItemFname: string;
  xml_episode: TXmlEpisode;
begin
  episode_text := '<item>' + '<title>The Eternal Eve by John Wyndham</title>' +
    '<enclosure url="\test_data\test_0\files\ToTHEBOWERS1829ByEdgarAllanPoe.pdf" length="11140" type="application/pdf" />' +
    '<description>22 pages, Amazing Stories, December 1950</description>' + '</item>';

  xml_episode := TXmlEpisode.Create(episode_text);
  url_and_filename := xml_episode.filenameAndUrl();
  ItemUrl := url_and_filename.EpisodeUrl;
  ItemFname := url_and_filename.EpisodeFilename;
  assertEquals('item_bits11 - Largest number without loss', '\test_data\test_0\files\ToTHEBOWERS1829ByEdgarAllanPoe.pdf', ItemUrl);
  assertEquals('item_bits22 - Largest number without loss', 'ToTHEBOWERS1829ByEdgarAllanPoe.pdf', ItemFname);

end;



initialization

  RegisterTest(TTestCaseXmlEpisode);

end.





