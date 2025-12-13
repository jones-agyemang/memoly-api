grouped_notes = (@results || {}).each_with_object([]) do |(collection_label, notes), memo|
  notes.each { |note| memo << [ collection_label, note ] }
end

json.array!(grouped_notes) do |(collection_label, note)|
  json.set! collection_label do
    json.id note.id
    json.raw_content note.raw_content
    json.source note.source
  end
end
