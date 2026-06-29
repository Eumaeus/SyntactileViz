module CEXParser

export Token, VerbalUnit, SyntacticRelation, Analysis, parse_cex

"""
    Token(id, text, vu_ids)

Represents one analyzed token.
"""
struct Token
    id::String
    text::String
    vu_ids::Vector{String}
end

"""
    VerbalUnit(id, syntactic_type, semantic_type, level)
"""
struct VerbalUnit
    id::String
    syntactic_type::String
    semantic_type::String
    level::Int
end

"""
    SyntacticRelation(source, target, relation)
"""
struct SyntacticRelation
    source::String
    target::String
    relation::String
end

"""
    Analysis(...)

Complete parsed analysis from a .cex file.
"""
struct Analysis
    cite_urn::String
    sentence_id::String
    sentence_text::String
    tokens::Vector{Token}
    verbal_units::Vector{VerbalUnit}
    relations::Vector{SyntacticRelation}
end

"""
    parse_cex(path::String) -> Analysis

Parse a Syntactile .cex file into structured Julia objects.
Works on the current sample files (Iliad and teacher examples).
"""
function parse_cex(path::String)::Analysis
    lines = readlines(path)

    cite_urn = ""
    sentence_id = ""
    sentence_text = ""
    tokens = Token[]
    verbal_units = VerbalUnit[]
    relations = SyntacticRelation[]

    i = 1
    while i <= length(lines)
        line = strip(lines[i])

        if startswith(line, "#!citelibrary")
            i += 1
            while i <= length(lines) && !startswith(strip(lines[i]), "#!")
                l = strip(lines[i])
                if startswith(l, "urn:cite2:")
                    cite_urn = l
                end
                i += 1
            end
            continue

        elseif startswith(line, "#!citedata")
            # Collect all data lines for this block
            data_lines = String[]
            i += 1
            while i <= length(lines) && !startswith(strip(lines[i]), "#!")
                push!(data_lines, strip(lines[i]))
                i += 1
            end

            if !isempty(data_lines)
                classify_and_parse_citedata!(data_lines, sentence_id, sentence_text, tokens, verbal_units)
            end
            continue

        elseif startswith(line, "#!citerelations")
            i += 1
            while i <= length(lines) && !startswith(strip(lines[i]), "#!")
                dl = strip(lines[i])
                if !isempty(dl) && occursin("#", dl)
                    parts = split(dl, "#"; limit=3)
                    if length(parts) == 3
                        push!(relations, SyntacticRelation(parts[1], parts[2], parts[3]))
                    end
                end
                i += 1
            end
            continue
        else
            i += 1
        end
    end

    return Analysis(cite_urn, sentence_id, sentence_text, tokens, verbal_units, relations)
end

# Internal helper to classify the different kinds of #!citedata blocks
function classify_and_parse_citedata!(data_lines, sentence_id_ref, sentence_text_ref, tokens, verbal_units)
    # Heuristics based on content patterns we see in the samples
    joined = join(data_lines, "\n")

    if occursin("VU", joined) && occursin("#", joined)
        # Verbal units block
        for dl in data_lines
            isempty(dl) && continue
            parts = split(dl, "#")
            if length(parts) >= 4
                # We don't want the property header line
                if (parts[1] != "unitId")
                    push!(verbal_units, VerbalUnit(
                        parts[1],
                        parts[2],
                        parts[3],
                        parse(Int, parts[4])
                    ))
                end
            end
        end
    elseif length(data_lines) == 1 && occursin("#", data_lines[1]) && count(c -> c == '#', data_lines[1]) == 1
        # Sentence block: id#full text
        parts = split(data_lines[1], "#"; limit=2)
        if length(parts) == 2
            sentence_id_ref[] = parts[1]          # mutate via Ref if needed, but we'll handle below
            sentence_text_ref[] = parts[2]
        end
    else
        # Token block: id#text#VUx or similar
        for dl in data_lines
            isempty(dl) && continue
            parts = split(dl, "#")
            if length(parts) >= 2
                tid = parts[1]
                ttext = parts[2]
                vus = length(parts) >= 3 ? split(parts[3], r"[,;]") : String[]
                push!(tokens, Token(tid, ttext, vus))
            end
        end
    end
end

end # module CEXParser