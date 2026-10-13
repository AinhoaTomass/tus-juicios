insert into storage.buckets (id, name, public)
values ('documentos', 'documentos', false)
on conflict (id) do nothing;

create policy "documentos_storage_owner_all"
on storage.objects for all
using (bucket_id = 'documentos' and (storage.foldername(name))[1] = auth.uid()::text)
with check (bucket_id = 'documentos' and (storage.foldername(name))[1] = auth.uid()::text);
