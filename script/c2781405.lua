-- ブラックロードの蛇 (Blacklord's Serpent)
local s, id = GetID()

function s.initial_effect(c)
    -- Cannot be Normal Summoned/Set
    c:EnableUnsummonable()

    -- Inherent Special Summon from GY by banishing 1 "Blacklord" monster
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Cannot be Special Summoned by other ways
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_SPSUMMON_CONDITION)
    e2:SetValue(s.splimit)
    c:RegisterEffect(e2)

    -- Once per turn: Target 1 monster your opponent controls; its ATK becomes 0 and negate its effects
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetTarget(s.atktg)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
end

function s.costfilter(c)
    return c:IsSetCard(0x2226) and c:IsAbleToRemoveAsCost()
end

function s.spcon(e, c)
    if c == nil then return true end
    return Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.costfilter, c:GetControler(), LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.costfilter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.splimit(e, se, sp, st)
    return (st & SUMMON_TYPE_SPECIAL) == SUMMON_TYPE_SPECIAL and se == nil
end

function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
    if chk == 0 then return Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_MZONE, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_MZONE, 1, 1, nil)
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(0)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(e1)
        if tc:IsType(TYPE_EFFECT) then
            local e2 = Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE)
            e2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(e2)
        end
    end
end