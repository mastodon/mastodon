# Extra magic

[['application/vnd.openxmlformats-officedocument.presentationml.presentation', [[0, "PK\003\004", [[30, '[Content_Types].xml', [[0..5000, 'ppt/']]]]]]],
 ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', [[0, "PK\003\004", [[30, '[Content_Types].xml', [[0..5000, 'xl/']]]]]]],
 ['application/vnd.openxmlformats-officedocument.wordprocessingml.document', [[0, "PK\003\004", [[30, '[Content_Types].xml', [[0..5000, 'word/']]]]]]]].each do |magic|
  MimeMagic.add(magic[0], magic: magic[1])
end
