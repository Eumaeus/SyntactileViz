module CEXParser

export Token, VerbalUnit, SyntacticRelation, Analysis, parse_cex

struct Token
    id::String
    text::String
    vu_ids::Vector{String}
end

struct VerbalUnit
    id::String
    syntactic_type::String
    semantic_type::String
    level::Int
end

struct SyntacticRelation
    source::String
    target::String
    relation::String
end

struct Analysis
    library_name::String
    analysis_urn::String
    passage_urn::String
    editor::String
    date::String
    sentence_urn::String
    sentence_text::String
    tokens::Vector{Token}
    verbal_units::Vector{VerbalUnit}
    relations::Vector{SyntacticRelation}
end

function parse_cex(path::String)::Analysis
    lines = readlines(path)

    # === Metadata ===
    library_name = ""
    analysis_urn = ""
    passage_urn = ""
    editor = ""
    date = ""

    # === Sentence info (will be set when we see the sentence block) ===
    sentence_urn = ""
    sentence_text = ""

    tokens = Token[]
    verbal_units = VerbalUnit[]
    relations = SyntacticRelation[]

    i = 1
    while i <= length(lines)
        line = strip(lines[i])

        if startswith(line, "#!citelibrary")
            i += 1
            while i <= length(lines)
                l = strip(lines[i])
                if startswith(l, "#!") 
                    break 
                end
                if occursin("#", l)
                    k, v = split(l, "#", limit=2)
                    k = strip(k)
                    v = strip(v)
                    if     k == "name"   library_name = v
                    elseif k == "urn"    analysis_urn = v
                    elseif k == "text"   passage_urn = v
                    elseif k == "editor" editor = v
                    elseif k == "date"   date = v
                    end
                end
                i += 1
            end
            continue

        elseif startswith(line, "#!citedata")
            i += 1
            if i > length(lines) 
                break 
            end
            header = strip(lines[i])
            i += 1

            data_lines = String[]
            while i <= length(lines)
                l = strip(lines[i])
                if startswith(l, "#!") 
                    break 
                end
                if !isempty(l) 
                    push!(data_lines, l) 
                end
                i += 1
            end

            # Handle sentence block directly here (only one exists)
            if occursin("sentence", header) && occursin("ctsurn", header)
                if !isempty(data_lines)
                    parts = split(data_lines[1], "#", limit=3)
                    if length(parts) >= 2
                        sentence_urn = strip(parts[2])
                    end
                    if length(parts) >= 3
                        sentence_text = strip(parts[3])
                    end
                end
            else
                parse_citedata_block!(header, data_lines, tokens, verbal_units)
            end

        elseif startswith(line, "#!citerelations")
            i += 1
            while i <= length(lines)
                l = strip(lines[i])
                if startswith(l, "#!") 
                    break 
                end
                if !isempty(l) && occursin("#", l)
                    parts = split(l, "#", limit=3)
                    if length(parts) == 3
                        src = strip(parts[1])
                        tgt = strip(parts[2])
                        rel = strip(parts[3])
                        if src != "source"   # skip repeated headers
                            push!(relations, SyntacticRelation(src, tgt, rel))
                        end
                    end
                end
                i += 1
            end

        else
            i += 1
        end
    end

    return Analysis(
        library_name,
        analysis_urn,
        passage_urn,
        editor,
        date,
        sentence_urn,
        sentence_text,
        tokens,
        verbal_units,
        relations
    )
end

function parse_citedata_block!(header::AbstractString, data_lines::Vector{String},
                               tokens::Vector{Token}, verbal_units::Vector{VerbalUnit})

    if occursin("tokenId", header)
        for dl in data_lines
            parts = split(dl, "#")
            if length(parts) >= 2
                tid   = strip(parts[1])
                ttext = strip(parts[2])
                vus = if length(parts) >= 3
                    filter(!isempty, split(strip(parts[3]), r"[,;]"))
                else
                    String[]
                end
                push!(tokens, Token(tid, ttext, vus))
            end
        end

    elseif occursin("unitId", header)
        for dl in data_lines
            parts = split(dl, "#")
            if length(parts) >= 4
                push!(verbal_units, VerbalUnit(
                    strip(parts[1]),
                    strip(parts[2]),
                    strip(parts[3]),
                    parse(Int, strip(parts[4]))
                ))
            end
        end
    end
end

end # module CEXParser