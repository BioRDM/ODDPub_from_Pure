import pypandoc


docx_file = '/home/dthedie/Documents/Data_sharing_evaluation/ODDPub_from_Pure/outputs/Files/999999999.docx'
output = pypandoc.convert_file(docx_file, 'plain')

print(output)
